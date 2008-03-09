From: Joe Perches <joe@perches.com>
Subject: [PATCH] include/net/route.h - remove duplicate include
Date: Sun, 09 Mar 2008 16:55:15 -0700
Message-ID: <1205106915.656.100.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 136-022.dsl.labridge.com ([206.117.136.22]:4363 "EHLO
	mail.perches.com" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1754861AbYCIX4O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Mar 2008 19:56:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Joe Perches <joe@perches.com>

 include/net/route.h |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/include/net/route.h b/include/net/route.h
index eadad59..28dba92 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -34,7 +34,6 @@
 #include <linux/ip.h>
 #include <linux/cache.h>
 #include <linux/security.h>
-#include <net/sock.h>
 
 #ifndef __KERNEL__
 #warning This file is not supposed to be used outside of kernel.


