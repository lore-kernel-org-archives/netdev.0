From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: [PATCH] fix for system lockups in 2.6.18-rcX caused by bcm43xx
Date: Sat, 9 Sep 2006 11:23:10 -0400
Message-ID: <20060909152305.GA27080@tuxdriver.com>
References: <45021D4A.6040805@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Stefano Brivio <st3-sGOZH3hwPm2sTnJN9+BGXg@public.gmane.org>,
	Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>,
	Broadcom Linux <bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <45021D4A.6040805-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
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

On Fri, Sep 08, 2006 at 08:47:54PM -0500, Larry Finger wrote:

> PLease send this upstream for inclusion in 2.6.18, if possible. This patch 
> will not work for
> wireless-2.6. That patch will be sent to you soon.

Are you saying this will break the upstream branch of wireless-2.6?
I'm not too excited about that.  Under the normal process, that would
mean 2.6.19 would be broken until we get the next patch.

When will the patch for the upstream branch be available?  Can you make
that patch based on this one (i.e. apply this one before generating
the next patch)?

John
-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
