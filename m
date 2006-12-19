From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 2/5] qla3xxx: Change version to v2.03.00-k2.
Date: Tue, 19 Dec 2006 10:22:36 -0800
Message-ID: <11665525593989-git-send-email-ron.mercer@qlogic.com>
References: <20061219181855.GA8179@linux-7mw0.qlogic.org>
Cc: ron.mercer@qlogic.com, benjamin.li@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:53404 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932878AbWLSSdE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Dec 2006 13:33:04 -0500
To: netdev@vger.kernel.org
In-Reply-To: <20061219181855.GA8179@linux-7mw0.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qla3xxx.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/qla3xxx.c b/drivers/net/qla3xxx.c
index c39f20d..ae65602 100644
--- a/drivers/net/qla3xxx.c
+++ b/drivers/net/qla3xxx.c
@@ -39,7 +39,7 @@ #include "qla3xxx.h"
 
 #define DRV_NAME  	"qla3xxx"
 #define DRV_STRING 	"QLogic ISP3XXX Network Driver"
-#define DRV_VERSION	"v2.02.00-k36"
+#define DRV_VERSION	"v2.03.00-k2"
 #define PFX		DRV_NAME " "
 
 static const char ql3xxx_driver_name[] = DRV_NAME;
-- 
1.4.2.rc2-dirty

