From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [patch 3/4] 2.6.5-rc2-mm5 - r8169 queue
Date: Mon, 29 Mar 2004 19:38:31 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040329193831.C5411@electric-eye.fr.zoreil.com>
References: <20040329193604.A4744@electric-eye.fr.zoreil.com> <20040329193710.A5411@electric-eye.fr.zoreil.com> <20040329193747.B5411@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20040329193747.B5411@electric-eye.fr.zoreil.com>; from romieu@fr.zoreil.com on Mon, Mar 29, 2004 at 07:37:47PM +0200
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

MAINTAINER entry for the r8169 driver.


 MAINTAINERS |    6 ++++++
 1 files changed, 6 insertions(+)

diff -puN MAINTAINERS~r8169-maintainer MAINTAINERS
--- linux-2.6.5-rc2-mm5/MAINTAINERS~r8169-maintainer	2004-03-29 18:58:06.000000000 +0200
+++ linux-2.6.5-rc2-mm5-fr/MAINTAINERS	2004-03-29 18:58:06.000000000 +0200
@@ -113,6 +113,12 @@ M:	jgarzik@pobox.com
 W:	http://sourceforge.net/projects/gkernel/
 S:	Maintained
 
+8169 10/100/1000 GIGABIT ETHERNET DRIVER
+P:	Francois Romieu
+M:	romieu@fr.zoreil.com
+L:	netdev@oss.sgi.com
+S:	Maintained
+
 8250/16?50 (AND CLONE UARTS) SERIAL DRIVER
 P:	Russell King
 M:	rmk+serial@arm.linux.org.uk

_
