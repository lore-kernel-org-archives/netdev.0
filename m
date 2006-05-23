From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 6/6] e1000: bump version to 7.0.38-k4
Date: Tue, 23 May 2006 14:08:51 -0700
Message-ID: <20060523210851.18540.54221.stgit@gitlost.site>
References: <20060523210740.18540.56647.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:63749 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S932261AbWEWVDx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 May 2006 17:03:53 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060523210740.18540.56647.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Auke Kok <auke.jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 95069ac..258c7d5 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -36,7 +36,7 @@ static char e1000_driver_string[] = "Int
 #else
 #define DRIVERNAPI "-NAPI"
 #endif
-#define DRV_VERSION "7.0.38-k2"DRIVERNAPI
+#define DRV_VERSION "7.0.38-k4"DRIVERNAPI
 char e1000_driver_version[] = DRV_VERSION;
 static char e1000_copyright[] = "Copyright (c) 1999-2006 Intel Corporation.";
 



--
Auke Kok <auke-jan.h.kok@intel.com>
