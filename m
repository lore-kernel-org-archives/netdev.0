From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: Re: Can someone please try...
Date: Tue, 16 Jan 2007 23:07:02 +0100
Message-ID: <200701162307.02891.mb@bu3sch.de>
References: <200701161806.02780.mb@bu3sch.de>
	<200701162023.23919.mb@bu3sch.de> <1168984238.16115.9.camel@dv>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
In-Reply-To: <1168984238.16115.9.camel@dv>
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

On Tuesday 16 January 2007 22:50, Pavel Roskin wrote:
> On Tue, 2007-01-16 at 20:23 +0100, Michael Buesch wrote:
> 
> > A patch for that is already upstream.
> 
> I don't see it.  It's not in your tree yet.

It is on its way upstream to linville.

> > It's surprising that it doesn't happen for me, though.
> > Neiter on PPC, nor on i386.
> 
> It did happen for me on i386, as well as on x86_64.  The dump was for
> x86_64, as evidenced by the register size.  Maybe you have less
> debugging options enabled?

All.

> > Patch was
> > [PATCH] bcm43xx-d80211: Fix DMA TX skb doublefree
> 
> Even with this hint, I cannot spot the bug immediately, so it would be
> great if you sync the public repository soon.

Linville has to put the patch into his tree first, so I can pull it.
You can find the patch easily by searching bcm43xx-dev or netdev
archives.

-- 
Greetings Michael.
