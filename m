From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: [PATCH] add bcm43xx-d80211 MAINTAINERS entry
Date: Wed, 16 Aug 2006 11:30:01 +0200
Message-ID: <200608161130.01458.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Content-Disposition: inline
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/bcm43xx-dev>
List-Post: <mailto:bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi John,

Please pull the patch to add Larry as bcm43xx-softmac
maintainer into wireless-dev and _after_ that please apply
the following patch to mark the d80211 branch explicitely.

--

Add MAINTAINERS for bcm43xx-d80211

Signed-off-by: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>

Index: wireless-dev/MAINTAINERS
===================================================================
--- wireless-dev.orig/MAINTAINERS	2006-08-16 11:26:18.000000000 +0200
+++ wireless-dev/MAINTAINERS	2006-08-16 11:27:29.000000000 +0200
@@ -456,6 +456,14 @@
 W:	http://www.baycom.org/~tom/ham/ham.html
 S:	Maintained
 
+BCM43XX WIRELESS DRIVER (DEVICESCAPE BASED VERSION)
+P:	Michael Buesch
+M:	mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org
+P:	Stefano Brivio
+M:	st3-sGOZH3hwPm2sTnJN9+BGXg@public.gmane.org
+W:	http://bcm43xx.berlios.de/
+S:	Maintained
+
 BCM43XX WIRELESS DRIVER (SOFTMAC BASED VERSION)
 P:	Larry Finger
 M:	Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org


-- 
Greetings Michael.
