From: Huang Weiyi <weiyi.huang@gmail.com>
Subject: [PATCH 6/9] glge: remove unused #include <version.h>
Date: Thu,  2 Apr 2009 23:33:55 +0800
Message-ID: <1238686435-216-1-git-send-email-weiyi.huang@gmail.com>
Cc: netdev@vger.kernel.org, Huang Weiyi <weiyi.huang@gmail.com>
To: ron.mercer@qlogic.com, linux-driver@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ti-out-0910.google.com ([209.85.142.191]:42522 "EHLO
	ti-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761026AbZDBPeD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2009 11:34:03 -0400
Received: by ti-out-0910.google.com with SMTP id i7so569717tid.23
        for <netdev@vger.kernel.org>; Thu, 02 Apr 2009 08:34:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove unused #include <version.h> in drivers/net/qlge/qlge_ethtool.

Signed-off-by: Huang Weiyi <weiyi.huang@gmail.com>
---
 drivers/net/qlge/qlge_ethtool.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/qlge/qlge_ethtool.c b/drivers/net/qlge/qlge_ethtool.c
index a500786..913b2a5 100644
--- a/drivers/net/qlge/qlge_ethtool.c
+++ b/drivers/net/qlge/qlge_ethtool.c
@@ -33,7 +33,6 @@
 #include <linux/mm.h>
 #include <linux/vmalloc.h>
 
-#include <linux/version.h>
 
 #include "qlge.h"
 
-- 
1.6.0.4

