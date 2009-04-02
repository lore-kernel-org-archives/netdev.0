From: Ramkrishna Vepa <ram.vepa@neterion.com>
Subject: [net-2.6 PATCH 2/9] Neterion: New driver: Update Maintainer list
Date: 01 Apr 2009 20:14:25 -0800
Message-ID: <1238645635.18544.213.camel@flash>
References: <1238194454.5516.379.camel@flash>
Reply-To: ram.vepa@neterion.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
	Ramkrishna Vepa <ram.vepa@neterion.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:33627 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759499AbZDBDdC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2009 23:33:02 -0400
In-Reply-To: <1238194454.5516.379.camel@flash>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- update to Maintainer list of S2IO 10GbE drivers (xframe/vxge).

Signed-off-by: Sivakumar Subramani <sivakumar.subramani@neterion.com>
Signed-off-by: Rastapur Santosh <santosh.rastapur@neterion.com>
Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
---
diff -urpN patch_1/MAINTAINERS patch_2/MAINTAINERS
--- patch_1/MAINTAINERS	2009-03-31 16:10:16.000000000 -0700
+++ patch_2/MAINTAINERS	2009-03-31 16:10:16.000000000 -0700
@@ -3111,7 +3111,7 @@ M:	shemminger@linux-foundation.org
 L:	netem@lists.linux-foundation.org
 S:	Maintained
 
-NETERION (S2IO) Xframe 10GbE DRIVER
+NETERION (S2IO) 10GbE DRIVER (xframe/vxge)
 P:	Ramkrishna Vepa
 M:	ram.vepa@neterion.com
 P:	Rastapur Santosh
@@ -3120,8 +3120,11 @@ P:	Sivakumar Subramani
 M:	sivakumar.subramani@neterion.com
 P:	Sreenivasa Honnur
 M:	sreenivasa.honnur@neterion.com
+P:	Anil Murthy
+M:	anil.murthy@neterion.com
 L:	netdev@vger.kernel.org
-W:	http://trac.neterion.com/cgi-bin/trac.cgi/wiki/TitleIndex?anonymous
+W:	http://trac.neterion.com/cgi-bin/trac.cgi/wiki/Linux?Anonymous
+W:	http://trac.neterion.com/cgi-bin/trac.cgi/wiki/X3100Linux?Anonymous
 S:	Supported
 
 NETFILTER/IPTABLES/IPCHAINS



