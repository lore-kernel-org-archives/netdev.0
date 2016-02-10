From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next] rds: duplicate include net/tcp.h
Date: Tue, 9 Feb 2016 22:04:47 -0800
Message-ID: <20160209220447.382b28a6@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Chien Yen <chien.yen@oracle.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:32990 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750759AbcBJGGB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2016 01:06:01 -0500
Received: by mail-pa0-f54.google.com with SMTP id cy9so6673989pac.0
        for <netdev@vger.kernel.org>; Tue, 09 Feb 2016 22:06:00 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Duplicate include detected.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

--- a/net/rds/tcp.c	2015-12-17 17:17:15.000000000 -0800
+++ b/net/rds/tcp.c	2016-02-09 22:02:23.491897938 -0800
@@ -37,7 +37,6 @@
 #include <net/tcp.h>
 #include <net/net_namespace.h>
 #include <net/netns/generic.h>
-#include <net/tcp.h>
 
 #include "rds.h"
 #include "tcp.h"
