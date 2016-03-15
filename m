From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Subject: [net-next iproute2 v2 2/2] man: update netconf manual for new attributes
Date: Tue, 15 Mar 2016 02:32:12 +0000
Message-ID: <1458009132-21621-3-git-send-email-zhangshengju@cmss.chinamobile.com>
References: <1458009132-21621-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Cc: netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta2.chinamobile.com ([221.176.66.80]:2876 "EHLO
	cmccmta2.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933499AbcCOC2U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2016 22:28:20 -0400
In-Reply-To: <1458009132-21621-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update this manual to add attributes proxy_neigh and
ignore_routes_with_linkdown.

Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
---
 man/man8/ip-netconf.8 | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/man/man8/ip-netconf.8 b/man/man8/ip-netconf.8
index 2718258..7fe3e5f 100644
--- a/man/man8/ip-netconf.8
+++ b/man/man8/ip-netconf.8
@@ -15,7 +15,7 @@ The
 .B ip netconf
 utility can monitor IPv4 and IPv6 parameters (see
 .BR "/proc/sys/net/ipv[4|6]/conf/[all|DEV]/" ")"
-like forwarding, rp_filter
+like forwarding, rp_filter, proxy_neigh, ignore_routes_with_linkdown
 or mc_forwarding status.
 
 If no interface is specified, the entry
-- 
1.8.3.1
