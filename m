From: Huang Weiyi <weiyi.huang@gmail.com>
Subject: [PATCH 5/9] dnet: remove unused #include <version.h>
Date: Thu,  2 Apr 2009 23:33:50 +0800
Message-ID: <1238686430-3912-1-git-send-email-weiyi.huang@gmail.com>
Cc: netdev@vger.kernel.org, Huang Weiyi <weiyi.huang@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ti-out-0910.google.com ([209.85.142.191]:42522 "EHLO
	ti-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757180AbZDBPd4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2009 11:33:56 -0400
Received: by ti-out-0910.google.com with SMTP id i7so569717tid.23
        for <netdev@vger.kernel.org>; Thu, 02 Apr 2009 08:33:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove unused #include <version.h> in drivers/net/dnet.c.

Signed-off-by: Huang Weiyi <weiyi.huang@gmail.com>
---
 drivers/net/dnet.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/dnet.c b/drivers/net/dnet.c
index db1e31f..33fa9ee 100644
--- a/drivers/net/dnet.c
+++ b/drivers/net/dnet.c
@@ -8,7 +8,6 @@
  * it under the terms of the GNU General Public License version 2 as
  * published by the Free Software Foundation.
  */
-#include <linux/version.h>
 #include <linux/io.h>
 #include <linux/module.h>
 #include <linux/moduleparam.h>
-- 
1.6.0.4

