From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 3/6] nfp: correct names of constants in comments
Date: Sat, 16 Apr 2016 11:25:51 +0100
Message-ID: <1460802354-14248-4-git-send-email-jakub.kicinski@netronome.com>
References: <1460802354-14248-1-git-send-email-jakub.kicinski@netronome.com>
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:36554 "EHLO
	mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751163AbcDPK0X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Apr 2016 06:26:23 -0400
Received: by mail-wm0-f45.google.com with SMTP id v188so60299614wme.1
        for <netdev@vger.kernel.org>; Sat, 16 Apr 2016 03:26:23 -0700 (PDT)
In-Reply-To: <1460802354-14248-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Documentation in comments lacks CFG in some names.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net_ctrl.h | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_ctrl.h b/drivers/net/ethernet/netronome/nfp/nfp_net_ctrl.h
index 8692003aeed8..3ec950555892 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_ctrl.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_ctrl.h
@@ -152,9 +152,9 @@
  * @NFP_NET_CFG_VERSION:     Firmware version number
  * @NFP_NET_CFG_STS:         Status
  * @NFP_NET_CFG_CAP:         Capabilities (same bits as @NFP_NET_CFG_CTRL)
- * @NFP_NET_MAX_TXRINGS:     Maximum number of TX rings
- * @NFP_NET_MAX_RXRINGS:     Maximum number of RX rings
- * @NFP_NET_MAX_MTU:         Maximum support MTU
+ * @NFP_NET_CFG_MAX_TXRINGS: Maximum number of TX rings
+ * @NFP_NET_CFG_MAX_RXRINGS: Maximum number of RX rings
+ * @NFP_NET_CFG_MAX_MTU:     Maximum support MTU
  * @NFP_NET_CFG_START_TXQ:   Start Queue Control Queue to use for TX (PF only)
  * @NFP_NET_CFG_START_RXQ:   Start Queue Control Queue to use for RX (PF only)
  *
-- 
1.9.1
