From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 4/6] e1000: Fix date string in Makefile
Date: Tue, 23 May 2006 14:08:47 -0700
Message-ID: <20060523210847.18540.41630.stgit@gitlost.site>
References: <20060523210740.18540.56647.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:61189 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S932255AbWEWVDt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 May 2006 17:03:49 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060523210740.18540.56647.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I forgot to update the date string in the Makefile last time.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/Makefile |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e1000/Makefile b/drivers/net/e1000/Makefile
index 92823ac..5dea2b7 100644
--- a/drivers/net/e1000/Makefile
+++ b/drivers/net/e1000/Makefile
@@ -1,7 +1,7 @@
 ################################################################################
 #
 # 
-# Copyright(c) 1999 - 2003 Intel Corporation. All rights reserved.
+# Copyright(c) 1999 - 2006 Intel Corporation. All rights reserved.
 # 
 # This program is free software; you can redistribute it and/or modify it 
 # under the terms of the GNU General Public License as published by the Free 



--
Auke Kok <auke-jan.h.kok@intel.com>
