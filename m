From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH net-next] liquidio: bump up driver version to 1.7.0 to match
 newer NIC firmware
Date: Wed, 1 Nov 2017 18:14:49 -0700
Message-ID: <20171102011449.GA6706@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0049.outbound.protection.outlook.com ([104.47.34.49]:36179
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752380AbdKBBOx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 1 Nov 2017 21:14:53 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
Acked-by: Derek Chickles <derek.chickles@cavium.com>
---
 drivers/net/ethernet/cavium/liquidio/liquidio_common.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/liquidio_common.h b/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
index 3bcdda8..522dcc4 100644
--- a/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
+++ b/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
@@ -27,8 +27,8 @@
 
 #define LIQUIDIO_PACKAGE ""
 #define LIQUIDIO_BASE_MAJOR_VERSION 1
-#define LIQUIDIO_BASE_MINOR_VERSION 6
-#define LIQUIDIO_BASE_MICRO_VERSION 1
+#define LIQUIDIO_BASE_MINOR_VERSION 7
+#define LIQUIDIO_BASE_MICRO_VERSION 0
 #define LIQUIDIO_BASE_VERSION   __stringify(LIQUIDIO_BASE_MAJOR_VERSION) "." \
 				__stringify(LIQUIDIO_BASE_MINOR_VERSION)
 #define LIQUIDIO_MICRO_VERSION  "." __stringify(LIQUIDIO_BASE_MICRO_VERSION)
