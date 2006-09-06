From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: Please pull from my tree
Date: Wed, 6 Sep 2006 22:58:48 +0200
Message-ID: <200609062258.48696.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bcm43xx-dev-tdrK/OAtAx2ELgA04lAiVw@public.gmane.org
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

Please do
git pull git://bu3sch.de/wireless-dev.git fixes-for-linville

This will pull a ssb fix I forgot to send upstream
via patches.

http://bu3sch.de/git?p=wireless-dev.git;a=commitdiff;h=e29495e14131be28da4fb8bf8a2615fd3f625764

 drivers/misc/ssb.c                                 |   29 +++++++++++++-------
 drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c |    6 ++++
 include/linux/ssb.h                                |   15 ++++++++++
 3 files changed, 39 insertions(+), 11 deletions(-)

-- 
Greetings Michael.
