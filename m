From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 5/5] qla3xxx: driver version change.
Date: Thu, 31 Jul 2008 13:46:08 -0700
Message-ID: <1217537168559-git-send-email-ron.mercer@qlogic.com>
References: <20080731204514.GA5457@susedev.qlogic.org>
Cc: netdev@vger.kernel.org, root <root@susedev (none) >
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:23911 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754335AbYGaUqN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jul 2008 16:46:13 -0400
In-Reply-To: <20080731204514.GA5457@susedev.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: root <root@susedev.(none)>


Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qla3xxx.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/qla3xxx.c b/drivers/net/qla3xxx.c
index 5821112..3c06358 100644
--- a/drivers/net/qla3xxx.c
+++ b/drivers/net/qla3xxx.c
@@ -38,7 +38,7 @@
 
 #define DRV_NAME  	"qla3xxx"
 #define DRV_STRING 	"QLogic ISP3XXX Network Driver"
-#define DRV_VERSION	"v2.03.00-k4"
+#define DRV_VERSION	"v2.03.00-k5"
 #define PFX		DRV_NAME " "
 
 static const char ql3xxx_driver_name[] = DRV_NAME;
-- 
1.5.0.rc4.16.g9e258

