From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next 1/1] phc: Update author's email address.
Date: Sat, 17 Mar 2012 09:39:29 +0100
Message-ID: <f71e832a13040f4110719e759ca0441c77255e5c.1331973209.git.richardcochran@gmail.com>
References: <cover.1331973209.git.richardcochran@gmail.com>
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:48972 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752280Ab2CQIjj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Mar 2012 04:39:39 -0400
Received: by mail-we0-f174.google.com with SMTP id x9so4560686wej.19
        for <netdev@vger.kernel.org>; Sat, 17 Mar 2012 01:39:39 -0700 (PDT)
In-Reply-To: <cover.1331973209.git.richardcochran@gmail.com>
In-Reply-To: <cover.1331973209.git.richardcochran@gmail.com>
References: <cover.1331973209.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This commit brings the author email address macros up to date for four
modules in the PTP Hardware Clock subsystem.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/freescale/gianfar_ptp.c |    2 +-
 drivers/net/phy/dp83640.c                    |    2 +-
 drivers/ptp/ptp_clock.c                      |    2 +-
 drivers/ptp/ptp_ixp46x.c                     |    2 +-
 4 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar_ptp.c b/drivers/net/ethernet/freescale/gianfar_ptp.c
index 83e0ed7..5fd620b 100644
--- a/drivers/net/ethernet/freescale/gianfar_ptp.c
+++ b/drivers/net/ethernet/freescale/gianfar_ptp.c
@@ -564,6 +564,6 @@ static struct platform_driver gianfar_ptp_driver = {
 
 module_platform_driver(gianfar_ptp_driver);
 
-MODULE_AUTHOR("Richard Cochran <richard.cochran@omicron.at>");
+MODULE_AUTHOR("Richard Cochran <richardcochran@gmail.com>");
 MODULE_DESCRIPTION("PTP clock using the eTSEC");
 MODULE_LICENSE("GPL");
diff --git a/drivers/net/phy/dp83640.c b/drivers/net/phy/dp83640.c
index ba3c591..dd7ae19 100644
--- a/drivers/net/phy/dp83640.c
+++ b/drivers/net/phy/dp83640.c
@@ -1243,7 +1243,7 @@ static void __exit dp83640_exit(void)
 }
 
 MODULE_DESCRIPTION("National Semiconductor DP83640 PHY driver");
-MODULE_AUTHOR("Richard Cochran <richard.cochran@omicron.at>");
+MODULE_AUTHOR("Richard Cochran <richardcochran@gmail.at>");
 MODULE_LICENSE("GPL");
 
 module_init(dp83640_init);
diff --git a/drivers/ptp/ptp_clock.c b/drivers/ptp/ptp_clock.c
index 10451a1..f519a13 100644
--- a/drivers/ptp/ptp_clock.c
+++ b/drivers/ptp/ptp_clock.c
@@ -340,6 +340,6 @@ no_region:
 subsys_initcall(ptp_init);
 module_exit(ptp_exit);
 
-MODULE_AUTHOR("Richard Cochran <richard.cochran@omicron.at>");
+MODULE_AUTHOR("Richard Cochran <richardcochran@gmail.com>");
 MODULE_DESCRIPTION("PTP clocks support");
 MODULE_LICENSE("GPL");
diff --git a/drivers/ptp/ptp_ixp46x.c b/drivers/ptp/ptp_ixp46x.c
index 803d665..6f2782b 100644
--- a/drivers/ptp/ptp_ixp46x.c
+++ b/drivers/ptp/ptp_ixp46x.c
@@ -327,6 +327,6 @@ no_master:
 module_init(ptp_ixp_init);
 module_exit(ptp_ixp_exit);
 
-MODULE_AUTHOR("Richard Cochran <richard.cochran@omicron.at>");
+MODULE_AUTHOR("Richard Cochran <richardcochran@gmail.com>");
 MODULE_DESCRIPTION("PTP clock using the IXP46X timer");
 MODULE_LICENSE("GPL");
-- 
1.7.2.5
