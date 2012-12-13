From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH iproute2 5/6] ip: term OPTIONS was used twice in 'ip route' man pages
Date: Thu, 13 Dec 2012 14:42:53 +0100
Message-ID: <1355406174-10586-5-git-send-email-nicolas.dichtel@6wind.com>
References: <1355406174-10586-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:40568 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751597Ab2LMNpS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2012 08:45:18 -0500
In-Reply-To: <1355406174-10586-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

INFO_SPEC already uses the term 'OPTIONS' and describe it.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 man/man8/ip-route.8.in | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/man/man8/ip-route.8.in b/man/man8/ip-route.8.in
index f06fcba..2c35a97 100644
--- a/man/man8/ip-route.8.in
+++ b/man/man8/ip-route.8.in
@@ -1,4 +1,4 @@
-.TH IP\-ROUTE 8 "20 Dec 2011" "iproute2" "Linux"
+.TH IP\-ROUTE 8 "13 Dec 2012" "iproute2" "Linux"
 .SH "NAME"
 ip-route \- routing table management
 .SH "SYNOPSIS"
@@ -7,7 +7,7 @@ ip-route \- routing table management
 .in +8
 .ti -8
 .B ip
-.RI "[ " OPTIONS " ]"
+.RI "[ " ip-OPTIONS " ]"
 .B route
 .RI " { " COMMAND " | "
 .BR help " }"
-- 
1.8.0.1
