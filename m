From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 8/8] qlcnic: update version to 5.0.1
Date: Wed, 31 Mar 2010 05:03:46 -0700
Message-ID: <1270037026-9062-9-git-send-email-amit.salecha@qlogic.com>
References: <1270037026-9062-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:60359 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S932232Ab0CaMDt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Mar 2010 08:03:49 -0400
In-Reply-To: <1270037026-9062-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index dbf6335..b726db2 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -51,8 +51,8 @@
 
 #define _QLCNIC_LINUX_MAJOR 5
 #define _QLCNIC_LINUX_MINOR 0
-#define _QLCNIC_LINUX_SUBVERSION 0
-#define QLCNIC_LINUX_VERSIONID  "5.0.0"
+#define _QLCNIC_LINUX_SUBVERSION 1
+#define QLCNIC_LINUX_VERSIONID  "5.0.1"
 
 #define QLCNIC_VERSION_CODE(a, b, c)	(((a) << 24) + ((b) << 16) + (c))
 #define _major(v)	(((v) >> 24) & 0xff)
-- 
1.6.0.2

