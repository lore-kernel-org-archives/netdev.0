From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 8/8] qlcnic: update version 5.0.8.0
Date: Wed, 11 Aug 2010 05:05:29 -0700
Message-ID: <1281528329-8812-9-git-send-email-amit.salecha@qlogic.com>
References: <1281528329-8812-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:61553 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1751845Ab0HKMFa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Aug 2010 08:05:30 -0400
In-Reply-To: <1281528329-8812-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

New field added to version number "_UPDATE",
to distinguish fixes and enhancement.

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic.h |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index 1d680a5..8e711f1 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -51,8 +51,9 @@
 
 #define _QLCNIC_LINUX_MAJOR 5
 #define _QLCNIC_LINUX_MINOR 0
-#define _QLCNIC_LINUX_SUBVERSION 7
-#define QLCNIC_LINUX_VERSIONID  "5.0.7"
+#define _QLCNIC_LINUX_SUBVERSION 8
+#define _QLCNIC_LINUX_UPDATE 0
+#define QLCNIC_LINUX_VERSIONID  "5.0.8.0"
 #define QLCNIC_DRV_IDC_VER  0x01
 
 #define QLCNIC_VERSION_CODE(a, b, c)	(((a) << 24) + ((b) << 16) + (c))
-- 
1.6.0.2

