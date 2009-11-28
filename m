From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 08/12] sfc: Remove some redundant whitespace
Date: Sat, 28 Nov 2009 15:35:36 +0000
Message-ID: <1259422536.3709.9.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:59154 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752190AbZK1Pft (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Nov 2009 10:35:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/net_driver.h |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index 57f8614..ca7dff2 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -866,9 +866,7 @@ struct efx_nic_type {
 	unsigned int buf_tbl_base;
 	unsigned int evq_ptr_tbl_base;
 	unsigned int evq_rptr_tbl_base;
-
 	u64 max_dma_mask;
-
 	unsigned int rx_buffer_padding;
 	unsigned int max_interrupt_mode;
 	unsigned int phys_addr_channels;
-- 
1.6.5.3




-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

