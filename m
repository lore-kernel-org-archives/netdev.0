From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 8/8] e1000: update version to 7.3.20-k2
Date: Fri, 12 Jan 2007 16:37:56 -0800
Message-ID: <20070113003756.16816.32137.stgit@gitlost.site>
References: <20070113003650.16816.34076.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:1197 "EHLO gitlost.site"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1161178AbXAMAyL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Jan 2007 19:54:11 -0500
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20070113003650.16816.34076.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index ae76479..2035ca4 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -36,7 +36,7 @@ static char e1000_driver_string[] = "Intel(R) PRO/1000 Network Driver";
 #else
 #define DRIVERNAPI "-NAPI"
 #endif
-#define DRV_VERSION "7.3.15-k2"DRIVERNAPI
+#define DRV_VERSION "7.3.20-k2"DRIVERNAPI
 char e1000_driver_version[] = DRV_VERSION;
 static char e1000_copyright[] = "Copyright (c) 1999-2006 Intel Corporation.";
 



---
Auke Kok <auke-jan.h.kok@intel.com>
