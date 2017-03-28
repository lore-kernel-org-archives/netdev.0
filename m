From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 1/4] ip: link: bond: Fix whitespace in help text
Date: Tue, 28 Mar 2017 23:19:36 +0200
Message-ID: <20170328211939.17922-2-phil@nwl.cc>
References: <20170328211939.17922-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:44175 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752401AbdC1VUt (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 28 Mar 2017 17:20:49 -0400
In-Reply-To: <20170328211939.17922-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 ip/iplink_bond.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ip/iplink_bond.c b/ip/iplink_bond.c
index fe83479a091a8..772b05fd89eaf 100644
--- a/ip/iplink_bond.c
+++ b/ip/iplink_bond.c
@@ -133,7 +133,7 @@ static void print_explain(FILE *f)
 		"                [ min_links MIN_LINKS ]\n"
 		"                [ lp_interval LP_INTERVAL ]\n"
 		"                [ packets_per_slave PACKETS_PER_SLAVE ]\n"
-		"		 [ tlb_dynamic_lb TLB_DYNAMIC_LB ]\n"
+		"                [ tlb_dynamic_lb TLB_DYNAMIC_LB ]\n"
 		"                [ lacp_rate LACP_RATE ]\n"
 		"                [ ad_select AD_SELECT ]\n"
 		"                [ ad_user_port_key PORTKEY ]\n"
-- 
2.11.0
