From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: Re: [PATCH] bcm43xx-softmac: add PCI-E code
Date: Mon, 23 Oct 2006 16:41:44 +0200
Message-ID: <200610231641.45011.mb@bu3sch.de>
References: <45330803.mail261110C22@lwfinger.net>
	<200610231529.05471.mb@bu3sch.de> <453CD325.3020003@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	Stefano Brivio <st3-sGOZH3hwPm2sTnJN9+BGXg@public.gmane.org>, John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
In-Reply-To: <453CD325.3020003-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
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

On Monday 23 October 2006 16:35, Daniel Drake wrote:
> Michael Buesch wrote:
> > Yeah, try to find out why.
> > I can only repeat myself: No developer has got a PCI-E card.
> > If there are problems, everybody has to find out by himself why
> > it does not work.
> > Try to find out why it can not determine the CHIP-ID.
> 
> Any point diagnosing this when this does not happen on 2.6.19-rc?

Yes. 2.6.19-rc is still older code than 2.6.18.1.
The stuff from 2.6.18.1 (which is the same as wireless-2.6)
will be merged into 2.6.19-rc soon.

> I'm sorry that I can't be more useful. The laptop has to head out of the 
> office later today. I may be able to continue playing with it in a few 
> weeks time.

ok.

-- 
Greetings Michael.
