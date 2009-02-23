From: Jesper Dangaard Brouer <jdb@comx.dk>
Subject: [PATCH 1/3] Doc: Fix typos in ip-sysctl.txt about rp_filter.
Date: Mon, 23 Feb 2009 15:37:55 +0100
Message-ID: <1235399875.2351.48.camel@localhost.localdomain>
References: <1235141957.2351.37.camel@localhost.localdomain>
	 <1235142193.2351.41.camel@localhost.localdomain>
	 <20090222.000656.74298101.davem@davemloft.net>
Reply-To: jdb@comx.dk
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:50893 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753024AbZBWOh7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Feb 2009 09:37:59 -0500
In-Reply-To: <20090222.000656.74298101.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


First fix a typo in Stephens patch ;-)

Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>
---

 Documentation/networking/ip-sysctl.txt |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)


diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 71041c2..e0b8c2c 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -711,8 +711,8 @@ rp_filter - INTEGER
 	    the packet check will fail.
 
         Current recommended practice in RFC3704 is to enable strict mode
-	to prevent IP spoofin from DDos attacks. If using asymmetric routing
-        or other complicated routing,t hen loose mode is recommended.
+	to prevent IP spoofing from DDos attacks. If using asymmetric routing
+        or other complicated routing, then loose mode is recommended.
 
 	conf/all/rp_filter must also be set to non-zero to do source validation
 	on the interface

