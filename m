From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 9/9] ixgb: increment version to 1.0.104-k2
Date: Tue, 23 May 2006 11:04:22 -0700
Message-ID: <20060523180422.17428.62409.stgit@gitlost.site>
References: <20060523180302.17428.89125.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke <auke-jan.h.kok"@intel.com,
	"Kok, Auke" <auke@foo-projects.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:49157 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S932162AbWEWR7Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 May 2006 13:59:24 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060523180302.17428.89125.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Increment the driver version to 1.0.104-k2

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>
---

 drivers/net/ixgb/ixgb_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index da0b919..0905a82 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -52,7 +52,7 @@ static char ixgb_driver_string[] = "Inte
 #else
 #define DRIVERNAPI "-NAPI"
 #endif
-#define DRV_VERSION		"1.0.100-k2"DRIVERNAPI
+#define DRV_VERSION		"1.0.104-k2"DRIVERNAPI
 char ixgb_driver_version[] = DRV_VERSION;
 static char ixgb_copyright[] = "Copyright (c) 1999-2005 Intel Corporation.";
 



--
Auke Kok <auke-jan.h.kok@intel.com>
