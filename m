From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 13/13] qla3xxx: Bumping driver version number
Date: Mon, 26 Feb 2007 11:06:43 -0800
Message-ID: <11725168041432-git-send-email-ron.mercer@qlogic.com>
References: <20070226190450.GA7325@linux-7mw0.qlogic.org>
Cc: ron.mercer@qlogic.com, romieu@fr.zoreil.com,
	benjamin.li@qlogic.com, netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:15768 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030473AbXBZTHt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Feb 2007 14:07:49 -0500
In-Reply-To: <20070226190450.GA7325@linux-7mw0.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Benjamin Li <benjamin.li@qlogic.com>

Signed-off-by: Benjamin Li <benjamin.li@qlogic.com>
Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qla3xxx.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/qla3xxx.c b/drivers/net/qla3xxx.c
index f446232..15f1371 100755
--- a/drivers/net/qla3xxx.c
+++ b/drivers/net/qla3xxx.c
@@ -39,7 +39,7 @@
 
 #define DRV_NAME  	"qla3xxx"
 #define DRV_STRING 	"QLogic ISP3XXX Network Driver"
-#define DRV_VERSION	"v2.02.00-k36"
+#define DRV_VERSION	"v2.03.00-k3"
 #define PFX		DRV_NAME " "
 
 static const char ql3xxx_driver_name[] = DRV_NAME;
-- 
1.5.0.rc4.16.g9e258

