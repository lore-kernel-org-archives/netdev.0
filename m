From: Adrian Bunk <bunk@fs.tum.de>
Subject: [2.6 patch] NET_IPIP help: remove no longer available URL
Date: Sat, 10 Jul 2004 21:33:29 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20040710193329.GW28324@fs.tum.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org-S266357AbUGJTdh@vger.kernel.org>
To: netdev@oss.sgi.com
Content-Disposition: inline
List-Id: netdev.vger.kernel.org

This patch solves Bugzilla #2445 by removing a no longer available URL 
from the help text for NET_IPIP.

Noted by Nils Hammar <m4341@bedug.com>.

Signed-off-by: Adrian Bunk <bunk@fs.tum.de>

--- linux-2.6.7-mm7-full/net/ipv4/Kconfig.old	2004-07-10 21:27:06.000000000 +0200
+++ linux-2.6.7-mm7-full/net/ipv4/Kconfig	2004-07-10 21:27:28.000000000 +0200
@@ -196,8 +196,7 @@
 	  can be useful if you want to make your (or some other) machine
 	  appear on a different network than it physically is, or to use
 	  mobile-IP facilities (allowing laptops to seamlessly move between
-	  networks without changing their IP addresses; check out
-	  <http://anchor.cs.binghamton.edu/~mobileip/LJ/index.html>).
+	  networks without changing their IP addresses).
 
 	  Saying Y to this option will produce two modules ( = code which can
 	  be inserted in and removed from the running kernel whenever you
