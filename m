From: amit.salecha@qlogic.com
Subject: [PATCH NEXT 8/8] qlcnic: update version to 5.0.6
Date: Tue, 22 Jun 2010 06:19:05 -0700
Message-ID: <1277212745-26857-9-git-send-email-amit.salecha@qlogic.com>
References: <1277212745-26857-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	Amit Kumar Salecha <amit.salecha@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:65249 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1755070Ab0FVNTJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jun 2010 09:19:09 -0400
In-Reply-To: <1277212745-26857-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amit Kumar Salecha <amit.salecha@qlogic.com>

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index 7fa761a..3675678 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -51,8 +51,8 @@
 
 #define _QLCNIC_LINUX_MAJOR 5
 #define _QLCNIC_LINUX_MINOR 0
-#define _QLCNIC_LINUX_SUBVERSION 5
-#define QLCNIC_LINUX_VERSIONID  "5.0.5"
+#define _QLCNIC_LINUX_SUBVERSION 6
+#define QLCNIC_LINUX_VERSIONID  "5.0.6"
 #define QLCNIC_DRV_IDC_VER  0x01
 
 #define QLCNIC_VERSION_CODE(a, b, c)	(((a) << 24) + ((b) << 16) + (c))
-- 
1.6.0.2

