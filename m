From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 4/9] Remove garbage from comment
Date: Wed, 7 May 2008 12:57:44 +0100
Message-ID: <20080507115744.GP2217@solarflare.com>
References: <20080507114121.GL2217@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:55749 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752759AbYEGL6H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2008 07:58:07 -0400
Content-Disposition: inline
In-Reply-To: <20080507114121.GL2217@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/mdio_10g.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sfc/mdio_10g.h b/drivers/net/sfc/mdio_10g.h
index 2214b6d..338c62c 100644
--- a/drivers/net/sfc/mdio_10g.h
+++ b/drivers/net/sfc/mdio_10g.h
@@ -95,7 +95,7 @@
 #define MDIO_PMAPMD_CTRL2_10_BT		(0xf)
 #define MDIO_PMAPMD_CTRL2_TYPE_MASK	(0xf)
 
-/* /\* PHY XGXS lane state *\/ */
+/* PHY XGXS lane state */
 #define MDIO_PHYXS_LANE_STATE		(0x18)
 #define MDIO_PHYXS_LANE_ALIGNED_LBN	(12)
 

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
