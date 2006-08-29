From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 26/26] ixgb: Increment version to 1.0.112-k2
Date: Tue, 29 Aug 2006 09:45:12 -0700
Message-ID: <20060829164512.6872.16708.stgit@gitlost.site>
References: <20060829164153.6872.1713.stgit@gitlost.site>
Cc: netdev@vger.kernel.org, akpm@osdl.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:63498 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S965102AbWH2Qg6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2006 12:36:58 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060829164153.6872.1713.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/ixgb/ixgb_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index ee12a85..e36dee1 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -36,7 +36,7 @@ static char ixgb_driver_string[] = "Inte
 #else
 #define DRIVERNAPI "-NAPI"
 #endif
-#define DRV_VERSION		"1.0.109-k4"DRIVERNAPI
+#define DRV_VERSION		"1.0.112-k2"DRIVERNAPI
 char ixgb_driver_version[] = DRV_VERSION;
 static char ixgb_copyright[] = "Copyright (c) 1999-2006 Intel Corporation.";
 



---
Auke Kok <auke-jan.h.kok@intel.com>
