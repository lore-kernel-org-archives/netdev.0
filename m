From: Simon Kagstrom <simon.kagstrom@netinsight.net>
Subject: [PATCH v2 7/7] via-velocity: Bump version
Date: Mon, 23 Nov 2009 15:31:45 +0100
Message-ID: <20091123153145.59ee6911@marrow.netinsight.se>
References: <20091120160633.77b7aee0@marrow.netinsight.se>
	<20091123152724.2871cf4d@marrow.netinsight.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, davej@redhat.com, shemminger@vyatta.com,
	romieu@fr.zoreil.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ernst.netinsight.se ([194.16.221.21]:31619 "HELO
	ernst.netinsight.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1755067AbZKWObr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2009 09:31:47 -0500
In-Reply-To: <20091123152724.2871cf4d@marrow.netinsight.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Simon Kagstrom <simon.kagstrom@netinsight.net>
---
 drivers/net/via-velocity.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/via-velocity.h b/drivers/net/via-velocity.h
index cf10801..6b5fc51 100644
--- a/drivers/net/via-velocity.h
+++ b/drivers/net/via-velocity.h
@@ -29,7 +29,7 @@
 
 #define VELOCITY_NAME          "via-velocity"
 #define VELOCITY_FULL_DRV_NAM  "VIA Networking Velocity Family Gigabit Ethernet Adapter Driver"
-#define VELOCITY_VERSION       "1.14"
+#define VELOCITY_VERSION       "1.15"
 
 #define VELOCITY_IO_SIZE	256
 #define VELOCITY_NAPI_WEIGHT	64
-- 
1.6.0.4

