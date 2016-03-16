From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Subject: [net-next] net: fix a comment typo
Date: Wed, 16 Mar 2016 09:12:46 +0000
Message-ID: <1458119566-22304-1-git-send-email-zhangshengju@cmss.chinamobile.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta2.chinamobile.com ([221.176.66.80]:2414 "EHLO
	cmccmta2.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964864AbcCPJIZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2016 05:08:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix a comment typo.

Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
---
 include/uapi/linux/if.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/uapi/linux/if.h b/include/uapi/linux/if.h
index 9cf2394..f802775 100644
--- a/include/uapi/linux/if.h
+++ b/include/uapi/linux/if.h
@@ -37,7 +37,7 @@
  * are shared for all types of net_devices. The sysfs entries are available
  * via /sys/class/net/<dev>/flags. Flags which can be toggled through sysfs
  * are annotated below, note that only a few flags can be toggled and some
- * other flags are always always preserved from the original net_device flags
+ * other flags are always preserved from the original net_device flags
  * even if you try to set them via sysfs. Flags which are always preserved
  * are kept under the flag grouping @IFF_VOLATILE. Flags which are volatile
  * are annotated below as such.
-- 
1.8.3.1
