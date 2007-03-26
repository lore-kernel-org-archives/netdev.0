From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 7/7] qla3xxx: Bumping driver version number to v2.03.00-k4
Date: Mon, 26 Mar 2007 13:43:03 -0700
Message-ID: <11749417841267-git-send-email-ron.mercer@qlogic.com>
References: <20070326164650.GA3822@linux-7mw0.qlogic.org>
Cc: ron.mercer@qlogic.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:9929 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753066AbXCZUnL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Mar 2007 16:43:11 -0400
In-Reply-To: <20070326164650.GA3822@linux-7mw0.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qla3xxx.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/qla3xxx.c b/drivers/net/qla3xxx.c
index 3a49fc9..2967c89 100755
--- a/drivers/net/qla3xxx.c
+++ b/drivers/net/qla3xxx.c
@@ -39,7 +39,7 @@
 
 #define DRV_NAME  	"qla3xxx"
 #define DRV_STRING 	"QLogic ISP3XXX Network Driver"
-#define DRV_VERSION	"v2.03.00-k3"
+#define DRV_VERSION	"v2.03.00-k4"
 #define PFX		DRV_NAME " "
 
 static const char ql3xxx_driver_name[] = DRV_NAME;
-- 
1.5.0.rc4.16.g9e258

