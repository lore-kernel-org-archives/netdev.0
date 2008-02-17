From: Grant Grundler <grundler@parisc-linux.org>
Subject: [PATCH] update TULIP MAINTAINERS
Date: Sun, 17 Feb 2008 11:53:49 -0700
Message-ID: <20080217185349.GC4402@colo.lackof.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kyle@parisc-linux.org,
	akpm@linux-foundation.org
To: jgarzik@pobox.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from colo.lackof.org ([198.49.126.79]:34273 "EHLO colo.lackof.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751247AbYBQSyH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Feb 2008 13:54:07 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff,
Kyle and I are co-maintaining tulip driver. Normally kyle will review
my patchs and submit them. I'll deal with bugzilla.kernel.org bugs and
try to resolve those bugs.

thanks,
grant

Signed-off-by: Grant Grundler <grundler@parisc-linux.org>

--- linux-2.6.24.1/MAINTAINERS-ORIG	2008-02-17 10:33:52.000000000 -0800
+++ linux-2.6.24.1/MAINTAINERS	2008-02-17 10:47:01.000000000 -0800
@@ -3776,10 +3776,13 @@
 W:	http://www.auk.cx/tms380tr/
 S:	Maintained
 
-TULIP NETWORK DRIVER
-L:	tulip-users@lists.sourceforge.net
-W:	http://sourceforge.net/projects/tulip/
-S:	Orphan
+TULIP NETWORK DRIVERS
+P:	Grant Grundler
+M:	grundler@parisc-linux.org
+P:	Kyle McMartin
+M:	kyle@parisc-linux.org
+L:	netdev@vger.kernel.org
+S:	Maintained
 
 TUN/TAP driver
 P:	Maxim Krasnyansky
