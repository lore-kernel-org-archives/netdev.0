From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 4/4] e1000: bump version to 7.1.9-k4
Date: Fri, 14 Jul 2006 16:29:50 -0700
Message-ID: <20060714232950.22378.72454.stgit@gitlost.site>
References: <20060714232452.22378.32866.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:12809 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S1945914AbWGNXXH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jul 2006 19:23:07 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060714232452.22378.32866.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Bump the version to 7.1.9-k4 to indicate three extra changes.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 154acb2..da62db8 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -36,7 +36,7 @@ static char e1000_driver_string[] = "Int
 #else
 #define DRIVERNAPI "-NAPI"
 #endif
-#define DRV_VERSION "7.1.9-k2"DRIVERNAPI
+#define DRV_VERSION "7.1.9-k4"DRIVERNAPI
 char e1000_driver_version[] = DRV_VERSION;
 static char e1000_copyright[] = "Copyright (c) 1999-2006 Intel Corporation.";
 



--
Auke Kok <auke-jan.h.kok@intel.com>
