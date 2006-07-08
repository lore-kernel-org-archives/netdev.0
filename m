From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH 1/2][ATM]: Typo in drivers/atm/Kconfig...
Date: Fri, 07 Jul 2006 20:50:00 -0400
Message-ID: <200607080050.k680o08f022160@relax.cmf.nrl.navy.mil>
Cc: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ginger.cmf.nrl.navy.mil ([134.207.12.161]:41939 "EHLO
	ginger.cmf.nrl.navy.mil") by vger.kernel.org with ESMTP
	id S932473AbWGHAuW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Jul 2006 20:50:22 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

please consider for 2.6.18 -- thanks!

[ATM]: Typo in drivers/atm/Kconfig...

From: Matt LaPlante <kernel1@cyberdogtech.com>
Signed-off-by: Charles Williams <chas@cmf.nrl.navy.mil>

---
commit 8bbf3465e23c41b92931e2d2172c184ccd1d2510
tree d1620632c703f8d67790a4f9971f154949399740
parent d0cddc7d78816bf6ceae9730eb51d78a73a62c15
author chas williams <chas@relax.cmf.nrl.navy.mil> Thu, 06 Jul 2006 12:38:03 -0400
committer chas williams <chas@relax.cmf.nrl.navy.mil> Thu, 06 Jul 2006 12:38:03 -0400

 drivers/atm/Kconfig |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/atm/Kconfig b/drivers/atm/Kconfig
index 01a9f1c..cfa5af8 100644
--- a/drivers/atm/Kconfig
+++ b/drivers/atm/Kconfig
@@ -398,7 +398,7 @@ config ATM_FORE200E_USE_TASKLET
 	default n
 	help
 	  This defers work to be done by the interrupt handler to a
-	  tasklet instead of hanlding everything at interrupt time.  This
+	  tasklet instead of handling everything at interrupt time.  This
 	  may improve the responsive of the host.
 
 config ATM_FORE200E_TX_RETRY
