From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 5/9] Remove kernel-doc comments for removed members of struct efx_nic
Date: Wed, 7 May 2008 12:58:13 +0100
Message-ID: <20080507115813.GQ2217@solarflare.com>
References: <20080507114121.GL2217@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:55753 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752759AbYEGL6b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2008 07:58:31 -0400
Content-Disposition: inline
In-Reply-To: <20080507114121.GL2217@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/net_driver.h |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index 6ffa711..9c285fb 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -667,8 +667,6 @@ union efx_multicast_hash {
  * @phy_op: PHY interface
  * @phy_data: PHY private data (including PHY-specific stats)
  * @mii: PHY interface
- * @phy_powered: PHY power state
- * @tx_disabled: PHY transmitter turned off
  * @link_up: Link status
  * @link_options: Link options (MII/GMII format)
  * @n_link_state_changes: Number of times the link has changed state

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
