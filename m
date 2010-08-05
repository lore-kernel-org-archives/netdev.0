From: Andrea Gelmini <andrea.gelmini@gelma.net>
Subject: [PATCH 12/15] net: sunrpc: removed duplicated #include
Date: Thu,  5 Aug 2010 15:51:36 +0200
Message-ID: <1281016299-23958-12-git-send-email-andrea.gelmini@gelma.net>
References: <1281016299-23958-1-git-send-email-andrea.gelmini@gelma.net>
Cc: Andrea Gelmini <andrea.gelmini@gelma.net>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Neil Brown <neilb@suse.de>,
	"David S. Miller" <davem@davemloft.net>,
	Frederic Weisbecker <fweisbec@gmail.com>,
	linux-nfs@vger.kernel.org, netdev@vger.kernel.org
To: gelma@gelma.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:60783 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760485Ab0HENw1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Aug 2010 09:52:27 -0400
Received: by mail-ew0-f46.google.com with SMTP id 23so2361126ewy.19
        for <netdev@vger.kernel.org>; Thu, 05 Aug 2010 06:52:27 -0700 (PDT)
In-Reply-To: <1281016299-23958-1-git-send-email-andrea.gelmini@gelma.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Andrea Gelmini <andrea.gelmini@gelma.net>
---
 net/sunrpc/cache.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index 58de76c..b75879b 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -34,7 +34,6 @@
 #include <linux/sunrpc/cache.h>
 #include <linux/sunrpc/stats.h>
 #include <linux/sunrpc/rpc_pipe_fs.h>
-#include <linux/smp_lock.h>
 
 #define	 RPCDBG_FACILITY RPCDBG_CACHE
 
-- 
1.7.2.1.85.g2d089

