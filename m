From: "John W. Linville" <linville@tuxdriver.com>
Subject: [PATCH] MAINTAINERS: changes for wireless
Date: Wed, 17 Dec 2014 12:07:05 -0500
Message-ID: <1418836025-9035-1-git-send-email-linville@tuxdriver.com>
Cc: linux-wireless@vger.kernel.org, davem@davemloft.net,
	"John W. Linville" <linville@tuxdriver.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:34783 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751108AbaLQRPU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2014 12:15:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

http://marc.info/?l=linux-wireless&m=141883202530292&w=2

This makes it official... :-)

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---
 MAINTAINERS | 19 ++++++++-----------
 1 file changed, 8 insertions(+), 11 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index fdffe962a16a..e82d31aeb936 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -6603,19 +6603,8 @@ L:	netdev@vger.kernel.org
 S:	Maintained
 
 NETWORKING [WIRELESS]
-M:	"John W. Linville" <linville@tuxdriver.com>
 L:	linux-wireless@vger.kernel.org
 Q:	http://patchwork.kernel.org/project/linux-wireless/list/
-T:	git git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git
-S:	Maintained
-F:	net/mac80211/
-F:	net/rfkill/
-F:	net/wireless/
-F:	include/net/ieee80211*
-F:	include/linux/wireless.h
-F:	include/uapi/linux/wireless.h
-F:	include/net/iw_handler.h
-F:	drivers/net/wireless/
 
 NETWORKING DRIVERS
 L:	netdev@vger.kernel.org
@@ -6636,6 +6625,14 @@ F:	include/linux/inetdevice.h
 F:	include/uapi/linux/if_*
 F:	include/uapi/linux/netdevice.h
 
+NETWORKING DRIVERS (WIRELESS)
+M:	Kalle Valo <kvalo@codeaurora.org>
+L:	linux-wireless@vger.kernel.org
+Q:	http://patchwork.kernel.org/project/linux-wireless/list/
+T:	git git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers.git/
+S:	Maintained
+F:	drivers/net/wireless/
+
 NETXEN (1/10) GbE SUPPORT
 M:	Manish Chopra <manish.chopra@qlogic.com>
 M:	Sony Chacko <sony.chacko@qlogic.com>
-- 
1.9.3
