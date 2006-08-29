From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 17/26] e100: increment version to 3.5.16-k2
Date: Tue, 29 Aug 2006 09:44:52 -0700
Message-ID: <20060829164452.6872.61350.stgit@gitlost.site>
References: <20060829164153.6872.1713.stgit@gitlost.site>
Cc: netdev@vger.kernel.org, akpm@osdl.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:48906 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S965092AbWH2Qgj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2006 12:36:39 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060829164153.6872.1713.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Increment the version of e100 to 3.5.16-k2, increment dates.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e100.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index a98e23a..23afdff 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -159,7 +159,7 @@
 
 #define DRV_NAME		"e100"
 #define DRV_EXT			"-NAPI"
-#define DRV_VERSION		"3.5.10-k4"DRV_EXT
+#define DRV_VERSION		"3.5.16-k2"DRV_EXT
 #define DRV_DESCRIPTION		"Intel(R) PRO/100 Network Driver"
 #define DRV_COPYRIGHT		"Copyright(c) 1999-2006 Intel Corporation"
 #define PFX			DRV_NAME ": "



---
Auke Kok <auke-jan.h.kok@intel.com>
