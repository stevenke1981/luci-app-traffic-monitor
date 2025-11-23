# Makefile for luci-app-trafficmon (nftables version)
# 適用於 OpenWrt 24.10+
# Place in: openwrt/package/luci-app-trafficmon/Makefile

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-trafficmon
PKG_VERSION:=2.0
PKG_RELEASE:=1

PKG_LICENSE:=MIT
PKG_MAINTAINER:=Your Name <your@email.com>

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-trafficmon
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=3. Applications
  TITLE:=LuCI Traffic Monitor (nftables)
  DEPENDS:=+luci-base +python3 +python3-light \
           +firewall4 +nftables +kmod-nft-core +kmod-nft-nat \
           +conntrack +kmod-nf-conntrack +kmod-nf-conntrack-netlink \
           +logread +jsonfilter
  PKGARCH:=all
endef

define Package/luci-app-trafficmon/description
  Traffic monitoring application for OpenWrt 24.10+ with per-app statistics.
  Uses nftables/firewall4 for traffic classification.
  Similar to Asuswrt-Merlin's traffic analyzer.
  
  Features:
  - Per-application traffic statistics (YouTube, Netflix, etc.)
  - Real-time traffic monitoring
  - DNS-based application identification
  - Integration with firewall4/nftables
  - Optional nDPI support for enhanced detection
endef

define Package/luci-app-trafficmon/conffiles
/etc/config/trafficmon
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/luci-app-trafficmon/install
	# LuCI controller
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	$(INSTALL_DATA) ./files/luci/controller/trafficmon.lua \
		$(1)/usr/lib/lua/luci/controller/trafficmon.lua
	
	# LuCI view
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/view/trafficmon
	$(INSTALL_DATA) ./files/luci/view/trafficmon/overview.htm \
		$(1)/usr/lib/lua/luci/view/trafficmon/overview.htm
	
	# LuCI i18n (可選)
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/i18n
	# $(INSTALL_DATA) ./files/luci/i18n/*.lmo $(1)/usr/lib/lua/luci/i18n/
	
	# Main daemon (nftables version)
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) ./files/trafficmon-daemon-nft \
		$(1)/usr/bin/trafficmon-daemon-nft
	
	# nftables manager
	$(INSTALL_BIN) ./files/trafficmon-nft-manager \
		$(1)/usr/bin/trafficmon-nft-manager
	
	# Init script
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/trafficmon.init \
		$(1)/etc/init.d/trafficmon
	
	# Config
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/trafficmon.config \
		$(1)/etc/config/trafficmon
	
	# nftables integration files
	$(INSTALL_DIR) $(1)/usr/share/nftables.d/ruleset-post
	$(INSTALL_DATA) ./files/nftables.d/99-trafficmon.nft \
		$(1)/usr/share/nftables.d/ruleset-post/99-trafficmon.nft
	
	# Documentation
	$(INSTALL_DIR) $(1)/usr/share/doc/trafficmon
	$(INSTALL_DATA) ./files/README.md \
		$(1)/usr/share/doc/trafficmon/README.md
endef

define Package/luci-app-trafficmon/postinst
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] || {
	# 清除 LuCI 緩存
	rm -f /tmp/luci-indexcache /tmp/luci-modulecache/*
	
	# 啟用並啟動服務
	/etc/init.d/trafficmon enable
	
	# 檢查 firewall4 是否正在運行
	if /etc/init.d/firewall running; then
		echo "Integrating with firewall4..."
		/usr/bin/trafficmon-nft-manager start
	fi
	
	# 配置 dnsmasq
	if ! uci get dhcp.@dnsmasq[0].logqueries >/dev/null 2>&1; then
		uci set dhcp.@dnsmasq[0].logqueries='1'
		uci commit dhcp
		echo "Enabled dnsmasq query logging"
	fi
	
	# 啟動服務
	/etc/init.d/trafficmon start
	
	echo ""
	echo "=========================================="
	echo "Traffic Monitor has been installed!"
	echo "Access it at: System > Status > Traffic Monitor"
	echo ""
	echo "Note: This version uses nftables/firewall4"
	echo "Compatible with OpenWrt 24.10+"
	echo "=========================================="
}
exit 0
endef

define Package/luci-app-trafficmon/prerm
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] || {
	/etc/init.d/trafficmon stop
	/etc/init.d/trafficmon disable
	
	# 清理 nftables 規則
	/usr/bin/trafficmon-nft-manager stop 2>/dev/null || true
	
	# 清除緩存
	rm -f /tmp/luci-indexcache /tmp/luci-modulecache/*
}
exit 0
endef

define Package/luci-app-trafficmon/postrm
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] || {
	# 清理數據目錄
	rm -rf /tmp/trafficmon
	
	echo "Traffic Monitor has been removed"
}
exit 0
endef

$(eval $(call BuildPackage,luci-app-trafficmon))
