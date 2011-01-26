From: Vlad Dogaru <ddvlad@rosedu.org>
Subject: [PATCH] iproute2: fix man page whitespace
Date: Wed, 26 Jan 2011 19:35:27 +0200
Message-ID: <1296063327-20867-1-git-send-email-ddvlad@rosedu.org>
Cc: Vlad Dogaru <ddvlad@rosedu.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [141.85.37.41] ([141.85.37.41]:60616 "EHLO swarm.cs.pub.ro"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751736Ab1AZRfb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Jan 2011 12:35:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Vlad Dogaru <ddvlad@rosedu.org>
---
 man/man8/ip.8 |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/man/man8/ip.8 b/man/man8/ip.8
index 8d55fa9..83b7358 100644
--- a/man/man8/ip.8
+++ b/man/man8/ip.8
@@ -42,7 +42,7 @@ ip \- show / manipulate routing, devices, policy routing and tunnels
 .RB "[ " mtu
 .IR MTU " ]"
 .br
-.BR type TYPE
+.BR type " TYPE"
 .RI "[ " ARGS " ]"
 
 .ti -8
@@ -51,7 +51,7 @@ ip \- show / manipulate routing, devices, policy routing and tunnels
 
 .ti -8
 .BI "ip link delete " DEVICE
-.BI type TYPE
+.BI type " TYPE"
 .RI "[ " ARGS " ]"
 
 .ti -8
-- 
1.7.1

