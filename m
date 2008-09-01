From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 51/52] sfc: Remove obsolete comment about PCI modes
Date: Mon, 1 Sep 2008 12:50:18 +0100
Message-ID: <20080901115017.GR7908@solarflare.com>
References: <20080901111621.GT7908@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:36016 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759770AbYIALuV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2008 07:50:21 -0400
Content-Disposition: inline
In-Reply-To: <20080901111621.GT7908@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/falcon_hwdefs.h |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sfc/falcon_hwdefs.h b/drivers/net/sfc/falcon_hwdefs.h
index e319fd6..5d584b0 100644
--- a/drivers/net/sfc/falcon_hwdefs.h
+++ b/drivers/net/sfc/falcon_hwdefs.h
@@ -117,7 +117,6 @@
 #define SF_PRST_WIDTH 1
 #define EE_PRST_LBN 8
 #define EE_PRST_WIDTH 1
-/* See pic_mode_t for decoding of this field */
 /* These bit definitions are extrapolated from the list of numerical
  * values for STRAP_PINS.
  */
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

