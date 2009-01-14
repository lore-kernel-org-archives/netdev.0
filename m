From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 33/34]bnx2x: Driver description update
Date: Wed, 14 Jan 2009 18:44:28 +0200
Message-ID: <1231951468.11301.154.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: "David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2905 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1764216AbZANQpo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jan 2009 11:45:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Driver supports the 57711 and 57711E as well but the description was out of
date

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index cc83388..2aa2943 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -69,7 +69,7 @@ static char version[] __devinitdata =
 	DRV_MODULE_NAME " " DRV_MODULE_VERSION " (" DRV_MODULE_RELDATE ")\n";
 
 MODULE_AUTHOR("Eliezer Tamir");
-MODULE_DESCRIPTION("Broadcom NetXtreme II BCM57710 Driver");
+MODULE_DESCRIPTION("Broadcom NetXtreme II BCM57710/57711/57711E Driver");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(DRV_MODULE_VERSION);
 
-- 
1.5.4.3




