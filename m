From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: [PATCH 4/5] atl1: fix typo in dma_req_block
Date: Thu, 19 Jul 2007 18:45:13 -0500
Message-ID: <11848887142978-git-send-email-jacliburn@bellsouth.net>
References: <1184888714454-git-send-email-jacliburn@bellsouth.net>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	atl1-devel@lists.sourceforge.net, csnook@redhat.com,
	Jay Cliburn <jacliburn@bellsouth.net>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from imf17aec.mail.bellsouth.net ([205.152.59.65]:58345 "EHLO
	imf17aec.mail.bellsouth.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759305AbXGSXpR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2007 19:45:17 -0400
In-Reply-To: <1184888714454-git-send-email-jacliburn@bellsouth.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

s/dam/dma

Signed-off-by: Jay Cliburn <jacliburn@bellsouth.net>
---
 drivers/net/atl1/atl1_hw.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/atl1/atl1_hw.h b/drivers/net/atl1/atl1_hw.h
index 100c09c..f0d7e82 100644
--- a/drivers/net/atl1/atl1_hw.h
+++ b/drivers/net/atl1/atl1_hw.h
@@ -929,8 +929,8 @@ enum atl1_dma_req_block {
 	atl1_dma_req_128 = 0,
 	atl1_dma_req_256 = 1,
 	atl1_dma_req_512 = 2,
-	atl1_dam_req_1024 = 3,
-	atl1_dam_req_2048 = 4,
+	atl1_dma_req_1024 = 3,
+	atl1_dma_req_2048 = 4,
 	atl1_dma_req_4096 = 5
 };
 
-- 
1.5.2.2

