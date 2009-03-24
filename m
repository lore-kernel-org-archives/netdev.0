From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: netfilter 25/41: Kconfig spelling fixes (trivial)
Date: Tue, 24 Mar 2009 15:20:08 +0100 (CET)
Message-ID: <alpine.LSU.2.00.0903241518400.32642@fbirervta.pbzchgretzou.qr>
References: <20090324140302.31401.37732.sendpatchset@x2.localnet> <20090324140336.31401.95313.sendpatchset@x2.localnet>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sovereign.computergmbh.de ([85.214.69.204]:42830 "EHLO
	sovereign.computergmbh.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761612AbZCXOUL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2009 10:20:11 -0400
In-Reply-To: <20090324140336.31401.95313.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tuesday 2009-03-24 15:03, Patrick McHardy wrote:
>commit 67c0d57930ff9a24c6c34abee1b01f7716a9b0e2
>Author: Stephen Hemminger <sheminger@vyatta.com>
>Date:   Mon Mar 16 15:17:23 2009 +0100
>
>    netfilter: Kconfig spelling fixes (trivial)
>    
>    Signed-off-by: Stephen Hemminger <sheminger@vyatta.com>
>    Signed-off-by: Patrick McHardy <kaber@trash.net>

Please add this patch as a followup commit.


parent 1d45209d89e647e9f27e4afa1f47338df73bc112 (v2.6.29-rc5-881-g1d45209)
commit 85982fcfd17fbb1000302e253f82edd88efa180c
Author: Jan Engelhardt <jengelh@medozas.de>
Date:   Tue Mar 24 15:18:17 2009 +0100

netfilter: trivial Kconfig spelling fixes

Supplements commit 67c0d57930ff9a24c6c34abee1b01f7716a9b0e2.

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
---
 net/ipv6/netfilter/Kconfig |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/netfilter/Kconfig b/net/ipv6/netfilter/Kconfig
index 625353a..29d643b 100644
--- a/net/ipv6/netfilter/Kconfig
+++ b/net/ipv6/netfilter/Kconfig
@@ -101,7 +101,7 @@ config IP6_NF_MATCH_HL
 	---help---
 	This is a backwards-compat option for the user's convenience
 	(e.g. when running oldconfig). It selects
-	COFNIG_NETFILTER_XT_MATCH_HL.
+	CONFIG_NETFILTER_XT_MATCH_HL.
 
 config IP6_NF_MATCH_IPV6HEADER
 	tristate '"ipv6header" IPv6 Extension Headers Match'
@@ -137,7 +137,7 @@ config IP6_NF_TARGET_HL
 	---help---
 	This is a backwards-compat option for the user's convenience
 	(e.g. when running oldconfig). It selects
-	COFNIG_NETFILTER_XT_TARGET_HL.
+	CONFIG_NETFILTER_XT_TARGET_HL.
 
 config IP6_NF_TARGET_LOG
 	tristate "LOG target support"
-- 
# Created with git-export-patch
