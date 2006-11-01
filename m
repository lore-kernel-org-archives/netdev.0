From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 17/18] e1000: increment version to 7.3.15-k2
Date: Wed, 01 Nov 2006 09:52:08 -0800
Message-ID: <20061101175207.2356.835.stgit@gitlost.site>
References: <20061101175043.2356.13659.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:24592 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S1946983AbWKARqT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2006 12:46:19 -0500
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20061101175043.2356.13659.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 71524b1..276eeb8 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -35,7 +35,7 @@ static char e1000_driver_string[] = "Int
 #else
 #define DRIVERNAPI "-NAPI"
 #endif
-#define DRV_VERSION "7.2.9-k4"DRIVERNAPI
+#define DRV_VERSION "7.3.15-k2"DRIVERNAPI
 char e1000_driver_version[] = DRV_VERSION;
 static char e1000_copyright[] = "Copyright (c) 1999-2006 Intel Corporation.";
 



---
Auke Kok <auke-jan.h.kok@intel.com>
