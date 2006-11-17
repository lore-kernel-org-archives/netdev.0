From: Benjamin Herrenschmidt <benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>
Subject: Re: [PATCH]: bcm43xx-d80211: fix hwcrypto issues (mcast)
Date: Fri, 17 Nov 2006 18:46:29 +1100
Message-ID: <1163749589.5826.5.camel@localhost.localdomain>
References: <ej09qf$2nv$1@sea.gmane.org> <200611120934.28133.mb@bu3sch.de>
	<20061114142959.GA17486@keitarou>  <200611161507.33971.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Paul TBBle Hampson <Paul.Hampson-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>,
	linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
In-Reply-To: <200611161507.33971.mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
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

On Thu, 2006-11-16 at 15:07 +0100, Michael Buesch wrote:
> This fixes various bcm43xx-d80211 hwcrypto issues,
> which mainly prevented mcast frames from being decrypted properly.
> 
> This is mostly a rewrite of the key managing code.
> Note that after this patch v3 firmware is no longer supported.

So what is the solution for Apple machines owner who only get a v3
firmware from Apple ? I remember you telling me the answer on irc but I
wanted to make it public :-) Some web site we can d/l the windows
updates and extract the FW ?

Cheers,
Ben.
