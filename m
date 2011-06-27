From: Jon Mason <mason@myri.com>
Subject: [PATCH 8/9] myri10ge: update version
Date: Mon, 27 Jun 2011 10:05:07 -0500
Message-ID: <1309187108-12715-8-git-send-email-mason@myri.com>
References: <1309187108-12715-1-git-send-email-mason@myri.com>
Cc: netdev@vger.kernel.org, Andrew Gallatin <gallatin@myri.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:39466 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752136Ab1F0PFs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2011 11:05:48 -0400
Received: by mail-pv0-f174.google.com with SMTP id 12so2905334pvg.19
        for <netdev@vger.kernel.org>; Mon, 27 Jun 2011 08:05:48 -0700 (PDT)
In-Reply-To: <1309187108-12715-1-git-send-email-mason@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update version and copyright

Signed-off-by: Jon Mason <mason@myri.com>
---
 drivers/net/myri10ge/myri10ge.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index 1e1681b..aae5de1 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -1,7 +1,7 @@
 /*************************************************************************
  * myri10ge.c: Myricom Myri-10G Ethernet driver.
  *
- * Copyright (C) 2005 - 2009 Myricom, Inc.
+ * Copyright (C) 2005 - 2011 Myricom, Inc.
  * All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without
@@ -79,7 +79,7 @@
 #include "myri10ge_mcp.h"
 #include "myri10ge_mcp_gen_header.h"
 
-#define MYRI10GE_VERSION_STR "1.5.2-1.459"
+#define MYRI10GE_VERSION_STR "1.5.3-1.534"
 
 MODULE_DESCRIPTION("Myricom 10G driver (10GbE)");
 MODULE_AUTHOR("Maintainer: help@myri.com");
-- 
1.7.5.4

