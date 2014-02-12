From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net-next 10/13] sfc: Update product naming
Date: Wed, 12 Feb 2014 19:00:07 +0000
Message-ID: <52FBC4B7.4030501@solarflare.com>
References: <52FBC3C2.7030103@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:50978 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752706AbaBLTAK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 14:00:10 -0500
In-Reply-To: <52FBC3C2.7030103@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>

We don't use 'Solarstorm' or 'Solarflare Communications' in full
any more.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
Signed-off-by: Shradha Shah <sshah@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c |    2 +-
 drivers/net/ethernet/sfc/efx.h |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 91acdc2..62d1a78 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -3271,6 +3271,6 @@ module_exit(efx_exit_module);
 
 MODULE_AUTHOR("Solarflare Communications and "
 	      "Michael Brown <mbrown@fensystems.co.uk>");
-MODULE_DESCRIPTION("Solarflare Communications network driver");
+MODULE_DESCRIPTION("Solarflare network driver");
 MODULE_LICENSE("GPL");
 MODULE_DEVICE_TABLE(pci, efx_pci_table);
diff --git a/drivers/net/ethernet/sfc/efx.h b/drivers/net/ethernet/sfc/efx.h
index dbd7b78..9903258 100644
--- a/drivers/net/ethernet/sfc/efx.h
+++ b/drivers/net/ethernet/sfc/efx.h
@@ -14,7 +14,7 @@
 #include "net_driver.h"
 #include "filter.h"
 
-/* Solarstorm controllers use BAR 0 for I/O space and BAR 2(&3) for memory */
+/* All controllers use BAR 0 for I/O space and BAR 2(&3) for memory */
 #define EFX_MEM_BAR 2
 
 /* TX */
