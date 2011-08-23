From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 5/5] be2net: remove unused variable
Date: Tue, 23 Aug 2011 11:11:55 +0530
Message-ID: <1314078115-8121-6-git-send-email-sathya.perla@emulex.com>
References: <1314078115-8121-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:27624 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753751Ab1HWFmw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2011 01:42:52 -0400
In-Reply-To: <1314078115-8121-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be.h |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index 868d7f4..c5f0516 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -347,7 +347,6 @@ struct be_adapter {
 	u32 beacon_state;	/* for set_phys_id */
 
 	bool eeh_err;
-	bool link_up;
 	u32 port_num;
 	bool promiscuous;
 	bool wol;
-- 
1.7.4

