From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 04/14] e1000e: update comments listing supported
	parts for each MAC family
Date: Fri, 21 Nov 2008 10:59:57 -0800
Message-ID: <20081121185957.32313.73934.stgit@gitlost.lost>
References: <20081121185859.32313.42332.stgit@gitlost.lost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta04.emeryville.ca.mail.comcast.net ([76.96.30.40]:44136 "EHLO
	QMTA04.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752595AbYKUTAR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2008 14:00:17 -0500
In-Reply-To: <20081121185859.32313.42332.stgit@gitlost.lost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Some branding strings (displayed via lspci) are missing from the comments in
various family-specific files in the driver.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/82571.c   |    1 +
 drivers/net/e1000e/ich8lan.c |    2 ++
 2 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/e1000e/82571.c b/drivers/net/e1000e/82571.c
index 3027ad5..cbb1707 100644
--- a/drivers/net/e1000e/82571.c
+++ b/drivers/net/e1000e/82571.c
@@ -28,6 +28,7 @@
 
 /*
  * 82571EB Gigabit Ethernet Controller
+ * 82571EB Gigabit Ethernet Controller (Copper)
  * 82571EB Gigabit Ethernet Controller (Fiber)
  * 82571EB Dual Port Gigabit Mezzanine Adapter
  * 82571EB Quad Port Gigabit Mezzanine Adapter
diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index 523b971..11f0dd3 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -27,6 +27,7 @@
 *******************************************************************************/
 
 /*
+ * 82562G 10/100 Network Connection
  * 82562G-2 10/100 Network Connection
  * 82562GT 10/100 Network Connection
  * 82562GT-2 10/100 Network Connection
@@ -40,6 +41,7 @@
  * 82566MM Gigabit Network Connection
  * 82567LM Gigabit Network Connection
  * 82567LF Gigabit Network Connection
+ * 82567V Gigabit Network Connection
  * 82567LM-2 Gigabit Network Connection
  * 82567LF-2 Gigabit Network Connection
  * 82567V-2 Gigabit Network Connection

