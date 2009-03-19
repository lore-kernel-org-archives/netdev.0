From: Huang Weiyi <weiyi.huang@gmail.com>
Subject: [PATCH] remove duplicated #include
Date: Thu, 19 Mar 2009 21:44:40 +0800
Message-ID: <1237470280-668-1-git-send-email-weiyi.huang@gmail.com>
Cc: netdev@vger.kernel.org, Huang Weiyi <weiyi.huang@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ti-out-0910.google.com ([209.85.142.191]:56182 "EHLO
	ti-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755661AbZCSNps (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2009 09:45:48 -0400
Received: by ti-out-0910.google.com with SMTP id i7so373837tid.23
        for <netdev@vger.kernel.org>; Thu, 19 Mar 2009 06:45:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Removed duplicated #include in drivers/net/dnet.c.

Signed-off-by: Huang Weiyi <weiyi.huang@gmail.com>
---
 drivers/net/dnet.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/dnet.c b/drivers/net/dnet.c
index 5c347f7..8a98d40 100644
--- a/drivers/net/dnet.c
+++ b/drivers/net/dnet.c
@@ -21,7 +21,6 @@
 #include <linux/dma-mapping.h>
 #include <linux/platform_device.h>
 #include <linux/phy.h>
-#include <linux/platform_device.h>
 
 #include "dnet.h"
 
-- 
1.6.0.4

