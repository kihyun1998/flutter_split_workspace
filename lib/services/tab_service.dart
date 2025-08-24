import '../models/tab_model.dart';

class TabService {
  static List<TabModel> addTab(List<TabModel> tabs, TabModel tab, {int? index}) {
    final newTabs = List<TabModel>.from(tabs);
    if (index != null && index >= 0 && index <= newTabs.length) {
      newTabs.insert(index, tab);
    } else {
      newTabs.add(tab);
    }
    return newTabs;
  }

  static List<TabModel> removeTab(List<TabModel> tabs, String tabId) {
    return tabs.where((tab) => tab.id != tabId).toList();
  }

  static String? activateTab(List<TabModel> tabs, String tabId) {
    final tabExists = tabs.any((tab) => tab.id == tabId);
    return tabExists ? tabId : null;
  }

  static List<TabModel> moveTab(List<TabModel> tabs, String tabId, int newIndex) {
    final tabIndex = tabs.indexWhere((tab) => tab.id == tabId);
    if (tabIndex == -1 || newIndex < 0 || newIndex >= tabs.length) {
      return tabs;
    }

    final newTabs = List<TabModel>.from(tabs);
    final tab = newTabs.removeAt(tabIndex);
    newTabs.insert(newIndex, tab);
    
    return newTabs;
  }

  static String? getNextActiveTab(List<TabModel> tabs, String removedTabId, String? currentActiveTabId) {
    if (currentActiveTabId != removedTabId) {
      return currentActiveTabId;
    }

    final remainingTabs = removeTab(tabs, removedTabId);
    if (remainingTabs.isEmpty) {
      return null;
    }

    final removedIndex = tabs.indexWhere((tab) => tab.id == removedTabId);
    if (removedIndex == -1) {
      return remainingTabs.first.id;
    }

    if (removedIndex < remainingTabs.length) {
      return remainingTabs[removedIndex].id;
    } else {
      return remainingTabs.last.id;
    }
  }

  static TabModel? findTab(List<TabModel> tabs, String tabId) {
    try {
      return tabs.firstWhere((tab) => tab.id == tabId);
    } catch (e) {
      return null;
    }
  }

  static bool hasTab(List<TabModel> tabs, String tabId) {
    return tabs.any((tab) => tab.id == tabId);
  }
}