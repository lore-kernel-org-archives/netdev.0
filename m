From: Adrian Bunk <bunk@fs.tum.de>
Subject: [2.4 patch] NET_IPIP help: remove no longer available URL
Date: Sat, 10 Jul 2004 21:34:07 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040710193407.GX28324@fs.tum.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch solves Bugzilla #2445 by removing a no longer available URL
from the help text for NET_IPIP.

Noted by Nils Hammar <m4341@bedug.com>.

Signed-off-by: Adrian Bunk <bunk@fs.tum.de>

--- linux-2.4.27-rc3-full/Documentation/Configure.help.old	2004-07-10 21:29:41.000000000 +0200
+++ linux-2.4.27-rc3-full/Documentation/Configure.help	2004-07-10 21:29:54.000000000 +0200
@@ -6172,8 +6172,7 @@
   can be useful if you want to make your (or some other) machine
   appear on a different network than it physically is, or to use
   mobile-IP facilities (allowing laptops to seamlessly move between
-  networks without changing their IP addresses; check out
-  <http://anchor.cs.binghamton.edu/~mobileip/LJ/index.html>).
+  networks without changing their IP addresses).
 
   Saying Y to this option will produce two modules ( = code which can
   be inserted in and removed from the running kernel whenever you
