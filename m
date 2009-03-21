From: Huang Weiyi <weiyi.huang@gmail.com>
Subject: [PATCH] atl1c: remove duplicated #include
Date: Sat, 21 Mar 2009 13:49:23 +0800
Message-ID: <1237614563-3644-1-git-send-email-weiyi.huang@gmail.com>
Cc: netdev@vger.kernel.org, Huang Weiyi <weiyi.huang@gmail.com>
To: jie.yang@atheros.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ti-out-0910.google.com ([209.85.142.184]:58102 "EHLO
	ti-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761132AbZCUFta (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Mar 2009 01:49:30 -0400
Received: by ti-out-0910.google.com with SMTP id i7so884676tid.23
        for <netdev@vger.kernel.org>; Fri, 20 Mar 2009 22:49:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove duplicated #include in drivers/net/atl1c/atl1c.h.

Signed-off-by: Huang Weiyi <weiyi.huang@gmail.com>
---
 drivers/net/atl1c/atl1c.h |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/atl1c/atl1c.h b/drivers/net/atl1c/atl1c.h
index ac11b84..e1658ef 100644
--- a/drivers/net/atl1c/atl1c.h
+++ b/drivers/net/atl1c/atl1c.h
@@ -45,7 +45,6 @@
 #include <linux/vmalloc.h>
 #include <linux/pagemap.h>
 #include <linux/tcp.h>
-#include <linux/mii.h>
 #include <linux/ethtool.h>
 #include <linux/if_vlan.h>
 #include <linux/workqueue.h>
-- 
1.6.0.4

