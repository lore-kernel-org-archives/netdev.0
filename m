From: Dimitris Michailidis <dm@chelsio.com>
Subject: [PATCH net-next 9/9] cxgb4: update driver version
Date: Mon,  2 Aug 2010 16:19:24 -0700
Message-ID: <1280791164-14181-10-git-send-email-dm@chelsio.com>
References: <1280791164-14181-1-git-send-email-dm@chelsio.com>
 <1280791164-14181-2-git-send-email-dm@chelsio.com>
 <1280791164-14181-3-git-send-email-dm@chelsio.com>
 <1280791164-14181-4-git-send-email-dm@chelsio.com>
 <1280791164-14181-5-git-send-email-dm@chelsio.com>
 <1280791164-14181-6-git-send-email-dm@chelsio.com>
 <1280791164-14181-7-git-send-email-dm@chelsio.com>
 <1280791164-14181-8-git-send-email-dm@chelsio.com>
 <1280791164-14181-9-git-send-email-dm@chelsio.com>
Cc: Dimitris Michailidis <dm@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:13670 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754106Ab0HBXT0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Aug 2010 19:19:26 -0400
Received: from maui.asicdesigners.com (maui.asicdesigners.com [10.192.180.15])
	by stargate.chelsio.com (8.13.1/8.13.1) with SMTP id o72NJQbL025647
	for <netdev@vger.kernel.org>; Mon, 2 Aug 2010 16:19:26 -0700
In-Reply-To: <1280791164-14181-9-git-send-email-dm@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Dimitris Michailidis <dm@chelsio.com>
---
 drivers/net/cxgb4/cxgb4_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/cxgb4/cxgb4_main.c b/drivers/net/cxgb4/cxgb4_main.c
index a4c4f52..c327527 100644
--- a/drivers/net/cxgb4/cxgb4_main.c
+++ b/drivers/net/cxgb4/cxgb4_main.c
@@ -67,7 +67,7 @@
 #include "t4fw_api.h"
 #include "l2t.h"
 
-#define DRV_VERSION "1.0.0-ko"
+#define DRV_VERSION "1.3.0-ko"
 #define DRV_DESC "Chelsio T4 Network Driver"
 
 /*
-- 
1.5.4

