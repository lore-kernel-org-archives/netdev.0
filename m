From: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH] fix for system lockups in 2.6.18-rcX caused by bcm43xx
Date: Sat, 09 Sep 2006 15:42:37 -0400
Message-ID: <4503192D.4010509@gentoo.org>
References: <45021D4A.6040805@lwfinger.net>
	<20060909152305.GA27080@tuxdriver.com>
	<4502E62B.5060601@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Broadcom Linux <bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>,
	Stefano Brivio <st3-sGOZH3hwPm2sTnJN9+BGXg@public.gmane.org>, Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>,
	Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
In-Reply-To: <4502E62B.5060601-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
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

John,

Larry Finger wrote:
> I would like to get a listing of patches for bcm43xx-softmac that are 
> queued but not yet applied, and the order in which they will be applied. 
> I want to make sure nothing has fallen through the cracks, and that the 
> patches will apply cleanly.

I know you have various other commitments but I would also find it 
beneficial if you could reduce the amount of time it takes between the 
patch arriving in your inbox and the commit appearing in 
wireless-2.6.git on kernel.org.

I'm currently waiting on the last few ZD1211 patches to appear in the 
git tree before sending the next few, since otherwise I have to 
backtrack and find out which patches I have already sent before 
producing the next batch.

I'm probably just being lazy -- the current scheme is workable, it is 
just a simple matter of convenience to have the patches appearing in git 
relatively quickly (even if there is still a delay before they head 
Jeffwards).

Thanks!
Daniel
