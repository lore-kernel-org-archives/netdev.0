From: jon@ringle.org
Subject: [PATCH net-next] net: encx24j600: Fix typos in Kconfig
Date: Thu,  8 Oct 2015 11:10:19 -0400
Message-ID: <1444317019-17630-1-git-send-email-jon@ringle.org>
Cc: Jon Ringle <jringle@gridpoint.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f52.google.com ([209.85.192.52]:35848 "EHLO
	mail-qg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933554AbbJHPKr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2015 11:10:47 -0400
Received: by qgx61 with SMTP id 61so44379062qgx.3
        for <netdev@vger.kernel.org>; Thu, 08 Oct 2015 08:10:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Ringle <jringle@gridpoint.com>

Signed-off-by: Jon Ringle <jringle@gridpoint.com>
---
 drivers/net/ethernet/microchip/Kconfig | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/microchip/Kconfig b/drivers/net/ethernet/microchip/Kconfig
index b45b28a..0c32fea 100644
--- a/drivers/net/ethernet/microchip/Kconfig
+++ b/drivers/net/ethernet/microchip/Kconfig
@@ -39,9 +39,9 @@ config ENCX24J600
     tristate "ENCX24J600 support"
     depends on SPI
     ---help---
-      Support for the Microchip ENC424J600 ethernet chip.
+      Support for the Microchip ENC424J600/624J600 ethernet chip.
 
       To compile this driver as a module, choose M here. The module will be
-      called enc424j600.
+      called encx24j600.
 
 endif # NET_VENDOR_MICROCHIP
-- 
2.4.1
