From: Davide Caratti <dcaratti@redhat.com>
Subject: [iproute PATCH 2/3] man: ip.8: add missing 'macsec' item to OBJECT list
Date: Tue, 30 Aug 2016 13:23:13 +0200
Message-ID: <a4151b180ab64257d90706a44b14ced0f7ce7f6b.1472552276.git.dcaratti@redhat.com>
References: <cover.1472552276.git.dcaratti@redhat.com>
Cc: stephen@networkplumber.org, sd@queasysnail.net, phil@nwl.cc
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42922 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757682AbcH3LX6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 30 Aug 2016 07:23:58 -0400
In-Reply-To: <cover.1472552276.git.dcaratti@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Davide Caratti <dcaratti@redhat.com>
---
 man/man8/ip.8 | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/man/man8/ip.8 b/man/man8/ip.8
index f11fc0b..8ecb199 100644
--- a/man/man8/ip.8
+++ b/man/man8/ip.8
@@ -21,7 +21,8 @@ ip \- show / manipulate routing, devices, policy routing and tunnels
 .IR OBJECT " := { "
 .BR link " | " address " | " addrlabel " | " route " | " rule " | " neigh " | "\
  ntable " | " tunnel " | " tuntap " | " maddress " | "  mroute " | " mrule " | "\
- monitor " | " xfrm " | " netns " | "  l2tp " | "  tcp_metrics " | " token " }"
+ monitor " | " xfrm " | " netns " | "  l2tp " | "  tcp_metrics " | " token " | "\
+ macsec " }"
 .sp
 
 .ti -8
-- 
2.5.5
