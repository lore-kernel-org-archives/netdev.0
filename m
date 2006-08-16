From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 02/13] e100: increment version to 3.5.10-k4
Date: Wed, 16 Aug 2006 14:56:19 -0700
Message-ID: <20060816215619.27080.59826.stgit@gitlost.site>
References: <20060816215336.27080.56147.stgit@gitlost.site>
Cc: netdev@vger.kernel.org, akpm@osdl.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:53769 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S932252AbWHPVsb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2006 17:48:31 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060816215336.27080.56147.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Increment the version of e100 to 3.5.10-k4, increment dates.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e100.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index 5de9843..e208c09 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
 
-  Copyright(c) 1999 - 2005 Intel Corporation. All rights reserved.
+  Copyright(c) 1999 - 2006 Intel Corporation. All rights reserved.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms of the GNU General Public License as published by the Free
@@ -158,10 +158,10 @@
 
 
 #define DRV_NAME		"e100"
-#define DRV_EXT		"-NAPI"
-#define DRV_VERSION		"3.5.10-k2"DRV_EXT
+#define DRV_EXT			"-NAPI"
+#define DRV_VERSION		"3.5.10-k4"DRV_EXT
 #define DRV_DESCRIPTION		"Intel(R) PRO/100 Network Driver"
-#define DRV_COPYRIGHT		"Copyright(c) 1999-2005 Intel Corporation"
+#define DRV_COPYRIGHT		"Copyright(c) 1999-2006 Intel Corporation"
 #define PFX			DRV_NAME ": "
 
 #define E100_WATCHDOG_PERIOD	(2 * HZ)



--
Auke Kok <auke-jan.h.kok@intel.com>
