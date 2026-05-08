import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

admin.initializeApp();

const db = admin.firestore();

// Helper to check if user is admin
async function isAdmin(uid: string): Promise<boolean> {
  const userDoc = await db.collection('users').doc(uid).get();
  return userDoc.exists && userDoc.data()?.isAdmin === true;
}

// Set Role function
export const setRole = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be logged in.');
  }

  // Check if caller is admin
  const callerIsAdmin = await isAdmin(context.auth.uid);
  if (!callerIsAdmin) {
    // Check if there are NO admins yet (bootstrap phase)
    const adminQuery = await db.collection('users').where('isAdmin', '==', true).limit(1).get();
    if (!adminQuery.empty) {
      throw new functions.https.HttpsError('permission-denied', 'Only admins can set roles.');
    }
  }

  const { userId, role, status } = data;
  if (!userId || role === undefined) {
    throw new functions.https.HttpsError('invalid-argument', 'Missing userId or role.');
  }

  const updates: any = { updatedAt: admin.firestore.FieldValue.serverTimestamp() };
  if (role === 'admin') updates.isAdmin = status;
  if (role === 'provider') updates.isProvider = status;

  await db.collection('users').doc(userId).update(updates);
  return { success: true };
});

// Process Order
export const processOrder = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be logged in.');
  }

  const { providerId, items, address, paymentMethod, notes, scheduledDate, userName, userPhone } = data;

  // 1. Validate Provider
  const providerDoc = await db.collection('providers').doc(providerId).get();
  if (!providerDoc.exists) {
    throw new functions.https.HttpsError('not-found', 'Provider not found.');
  }
  const providerData = providerDoc.data()!;

  // 2. Validate Items & Prices
  let totalAmount = 0;
  const validatedItems = [];
  for (const item of items) {
    const service = providerData.services.find((s: any) => s.id === item.serviceId || s.name === item.serviceName);
    if (!service) {
      throw new functions.https.HttpsError('invalid-argument', `Service ${item.serviceName} not found.`);
    }
    totalAmount += service.price * (item.quantity || 1);
    validatedItems.push({
      serviceId: item.serviceId || '',
      serviceName: service.name,
      price: service.price,
      quantity: item.quantity || 1,
      unit: service.unit || null
    });
  }

  // 3. Create Order
  const orderData = {
    userId: context.auth.uid,
    providerId,
    providerName: providerData.shopName,
    providerPhone: providerData.phone,
    userName: userName || 'User',
    userPhone: userPhone || '',
    items: validatedItems,
    totalAmount,
    finalAmount: totalAmount,
    address: address || '',
    paymentMethod: paymentMethod || 'COD',
    status: 'pending',
    notes: notes || '',
    scheduledDate: scheduledDate ? admin.firestore.Timestamp.fromDate(new Date(scheduledDate)) : null,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    isRated: false
  };

  const orderRef = await db.collection('orders').add(orderData);
  return { orderId: orderRef.id };
});

// Update Order Status
export const updateOrderStatus = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be logged in.');
  }

  const { orderId, status, cancellationReason } = data;
  const orderDoc = await db.collection('orders').doc(orderId).get();
  if (!orderDoc.exists) {
    throw new functions.https.HttpsError('not-found', 'Order not found.');
  }

  const order = orderDoc.data()!;
  const uid = context.auth.uid;
  const userIsAdmin = await isAdmin(uid);

  const isProvider = order.providerId === uid || (await db.collection('providers').where('userId', '==', uid).get()).docs.length > 0;
  const isUser = order.userId === uid;

  if (!userIsAdmin && !isProvider && !isUser) {
    throw new functions.https.HttpsError('permission-denied', 'Unauthorized.');
  }

  if (isUser && status !== 'cancelled') {
     throw new functions.https.HttpsError('permission-denied', 'Users can only cancel orders.');
  }

  const updates: any = {
    status,
    updatedAt: admin.firestore.FieldValue.serverTimestamp()
  };

  if (status === 'cancelled' && cancellationReason) {
    updates.cancellationReason = cancellationReason;
  }

  if (status === 'completed') {
    updates.completedAt = admin.firestore.FieldValue.serverTimestamp();
  }

  await db.collection('orders').doc(orderId).update(updates);
  return { success: true };
});

// Submit Review
export const submitReview = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be logged in.');
  }

  const { orderId, rating, comment, userName } = data;
  const orderDoc = await db.collection('orders').doc(orderId).get();
  
  if (!orderDoc.exists || orderDoc.data()?.userId !== context.auth.uid) {
    throw new functions.https.HttpsError('permission-denied', 'Invalid order.');
  }

  if (orderDoc.data()?.status !== 'completed') {
    throw new functions.https.HttpsError('failed-precondition', 'Can only review completed orders.');
  }

  const order = orderDoc.data()!;
  
  // Create Review
  const reviewData = {
    userId: context.auth.uid,
    userName: userName || 'User',
    providerId: order.providerId,
    orderId,
    rating,
    comment: comment || '',
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp()
  };

  await db.collection('reviews').add(reviewData);
  await db.collection('orders').doc(orderId).update({ isRated: true });

  // Update Provider Rating
  const reviewsSnapshot = await db.collection('reviews').where('providerId', '==', order.providerId).get();
  const reviews = reviewsSnapshot.docs.map(d => d.data());
  const avgRating = reviews.reduce((acc, r) => acc + r.rating, 0) / reviews.length;

  await db.collection('providers').doc(order.providerId).update({
    rating: avgRating,
    reviewCount: reviews.length,
    updatedAt: admin.firestore.FieldValue.serverTimestamp()
  });

  return { success: true };
});

// Admin Analytics
export const getAdminAnalytics = functions.https.onCall(async (data, context) => {
  if (!context.auth || !(await isAdmin(context.auth.uid))) {
    throw new functions.https.HttpsError('permission-denied', 'Admin only.');
  }

  const usersCount = (await db.collection('users').count().get()).data().count;
  const providersCount = (await db.collection('providers').count().get()).data().count;
  const ordersCount = (await db.collection('orders').count().get()).data().count;

  const completedOrders = await db.collection('orders').where('status', '==', 'completed').get();
  const totalRevenue = completedOrders.docs.reduce((acc, doc) => acc + (doc.data().finalAmount || 0), 0);

  return {
    totalUsers: usersCount,
    totalProviders: providersCount,
    totalOrders: ordersCount,
    totalRevenue,
    completedOrders: completedOrders.size
  };
});
// Purchase Subscription
export const purchaseSubscription = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be logged in.');
  }

  const { planId, price, durationMonths } = data;
  if (!planId) {
    throw new functions.https.HttpsError('invalid-argument', 'Missing planId.');
  }

  const expiryDate = new Date();
  expiryDate.setMonth(expiryDate.getMonth() + (durationMonths || 1));

  const subscriptionData = {
    userId: context.auth.uid,
    planId,
    price: price || 0,
    status: 'active',
    startDate: admin.firestore.FieldValue.serverTimestamp(),
    expiryDate: admin.firestore.Timestamp.fromDate(expiryDate),
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp()
  };

  // 1. Save subscription record
  await db.collection('subscriptions').add(subscriptionData);

  // 2. Update user document
  await db.collection('users').doc(context.auth.uid).update({
    subscriptionPlan: planId,
    subscriptionExpiry: admin.firestore.Timestamp.fromDate(expiryDate),
    isPremium: planId !== 'free',
    updatedAt: admin.firestore.FieldValue.serverTimestamp()
  });

  return { success: true, expiryDate: expiryDate.toISOString() };
});
