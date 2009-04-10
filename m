From: Andy Grover <andy.grover@oracle.com>
Subject: [PATCH 08/12] RDS: remove unused #include <version.h>
Date: Thu,  9 Apr 2009 17:09:43 -0700
Message-ID: <1239322187-3764-9-git-send-email-andy.grover@oracle.com>
References: <1239322187-3764-1-git-send-email-andy.grover@oracle.com>
Cc: rds-devel@oss.oracle.com, Huang Weiyi <weiyi.huang@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:39372 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S937311AbZDJAKO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2009 20:10:14 -0400
In-Reply-To: <1239322187-3764-1-git-send-email-andy.grover@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Huang Weiyi <weiyi.huang@gmail.com>

Remove unused #include <version.h> in net/rds/af_rds.c.

Signed-off-by: Huang Weiyi <weiyi.huang@gmail.com>
Signed-off-by: Andy Grover <andy.grover@oracle.com>
---
 net/rds/af_rds.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/net/rds/af_rds.c b/net/rds/af_rds.c
index 20cf16f..b11e7e5 100644
--- a/net/rds/af_rds.c
+++ b/net/rds/af_rds.c
@@ -35,7 +35,6 @@
 #include <linux/kernel.h>
 #include <linux/in.h>
 #include <linux/poll.h>
-#include <linux/version.h>
 #include <net/sock.h>
 
 #include "rds.h"
-- 
1.5.6.3

