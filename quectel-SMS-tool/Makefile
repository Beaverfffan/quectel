include $(TOPDIR)/rules.mk

PKG_NAME:= quectel-SMS-tool
PKG_RELEASE:=1
PKG_VERSION:=1.0

include $(INCLUDE_DIR)/package.mk

define Package/quectel-SMS-tool
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=quectel-SMS-tool
endef

define Package/quectel-SMS-tool/description
	quectel-SMS-tool
endef

define Build/Compile
	$(MAKE) -C "$(PKG_BUILD_DIR)" \
		CROSS_COMPILE="$(TARGET_CROSS)" \
		ARCH="$(LINUX_KARCH)" \
		SUBDIRS="$(PKG_BUILD_DIR)" \
		EXTRA_CFLAGS="$(EXTRA_CFLAGS)" \
		CC="$(TARGET_CC)"
endef

define Package/quectel-SMS-tool/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/sms_tool $(1)/usr/bin/
endef

$(eval $(call BuildPackage,quectel-SMS-tool))
