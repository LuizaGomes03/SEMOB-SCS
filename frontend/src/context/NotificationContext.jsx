import React, { createContext, useContext, useState } from 'react';
import { MOCK_NOTIFICATIONS } from '../data/mockData';

const NotificationContext = createContext();

export function NotificationProvider({ children }) {
  const [notifications, setNotifications] = useState(MOCK_NOTIFICATIONS);
  const [isDrawerOpen, setIsDrawerOpen] = useState(false);
  const [activeCategory, setActiveCategory] = useState('Todas');

  const unreadCount = notifications.filter((n) => !n.read).length;

  const toggleDrawer = () => {
    setIsDrawerOpen((prev) => !prev);
  };

  const markAsRead = (id) => {
    setNotifications((prev) =>
      prev.map((n) => (n.id === id ? { ...n, read: true } : n))
    );
  };

  const markAllAsRead = () => {
    setNotifications((prev) => prev.map((n) => ({ ...n, read: true })));
  };

  const clearAll = () => {
    setNotifications([]);
  };

  const filteredNotifications =
    activeCategory === 'Todas'
      ? notifications
      : notifications.filter((n) => n.category === activeCategory);

  return (
    <NotificationContext.Provider
      value={{
        notifications: filteredNotifications,
        allNotifications: notifications,
        unreadCount,
        isDrawerOpen,
        setIsDrawerOpen,
        toggleDrawer,
        markAsRead,
        markAllAsRead,
        clearAll,
        activeCategory,
        setActiveCategory
      }}
    >
      {children}
    </NotificationContext.Provider>
  );
}

export function useNotifications() {
  const context = useContext(NotificationContext);
  if (!context) {
    throw new Error('useNotifications deve ser utilizado dentro de NotificationProvider');
  }
  return context;
}
