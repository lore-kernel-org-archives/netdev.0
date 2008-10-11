From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 6/6] [NET-NEXT]qlge: Version change to v1.00.00-b4.
Date: Sat, 11 Oct 2008 10:17:13 -0700
Message-ID: <1223745433-26440-6-git-send-email-ron.mercer@qlogic.com>
References: <20081011171614.GA26384@susedev.qlogic.org>
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com,
	ron.mercer@qlogic.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:13301 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760595AbYJKRRS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Oct 2008 13:17:18 -0400
In-Reply-To: <20081011171614.GA26384@susedev.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/qlge/qlge.h b/drivers/net/qlge/qlge.h
index 42fd24a..4de78d5 100755
--- a/drivers/net/qlge/qlge.h
+++ b/drivers/net/qlge/qlge.h
@@ -15,7 +15,7 @@
  */
 #define DRV_NAME  	"qlge"
 #define DRV_STRING 	"QLogic 10 Gigabit PCI-E Ethernet Driver "
-#define DRV_VERSION	"v1.00.00-b3"
+#define DRV_VERSION	"v1.00.00-b4"
 
 #define PFX "qlge: "
 #define QPRINTK(qdev, nlevel, klevel, fmt, args...)     \
-- 
1.6.0

