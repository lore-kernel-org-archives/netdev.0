From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: [PATCH] Add Larry Finger to bcm43xx MAINTAINERS
Date: Wed, 16 Aug 2006 00:39:36 +0200
Message-ID: <200608160039.37200.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
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

Hi,

I officially drop my maintainance of the bcm43xx-softmac
driver now with this mail. Larry will continue with my
work on the bcm43xx-softmac driver.

I will instead focus on the bcm43xx-d80211 driver and on
the implementation of the new v4 specs.

So if someone wants to send some bcm43xx-softmac patch
upstream, the person to send it to is Larry.
Larry will also take care of backporting fixes from
the bcm43xx-d80211 branch to bcm43xx-softmac.

So John, please apply the following patch to wireless-2.6.

--

Remove Michael Buesch and add Larry Finger in the
bcm43xx-softmac MAINTAINERS record.

Signed-off-by: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>

Index: wireless-2.6/MAINTAINERS
===================================================================
--- wireless-2.6.orig/MAINTAINERS	2006-08-15 16:51:43.000000000 +0200
+++ wireless-2.6/MAINTAINERS	2006-08-16 00:32:46.000000000 +0200
@@ -449,9 +449,9 @@
 W:	http://www.baycom.org/~tom/ham/ham.html
 S:	Maintained
 
-BCM43XX WIRELESS DRIVER
-P:	Michael Buesch
-M:	mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org
+BCM43XX WIRELESS DRIVER (SOFTMAC BASED VERSION)
+P:	Larry Finger
+M:	Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org
 P:	Stefano Brivio
 M:	st3-sGOZH3hwPm2sTnJN9+BGXg@public.gmane.org
 W:	http://bcm43xx.berlios.de/

-- 
Greetings Michael.
