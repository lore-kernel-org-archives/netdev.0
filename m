From: Benjamin Herrenschmidt <benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>
Subject: Re: [PATCH]: bcm43xx-d80211: fix hwcrypto issues (mcast)
Date: Fri, 17 Nov 2006 19:02:53 +1100
Message-ID: <1163750573.5826.7.camel@localhost.localdomain>
References: <ej09qf$2nv$1@sea.gmane.org> <200611120934.28133.mb@bu3sch.de>
	<20061114142959.GA17486@keitarou>  <200611161507.33971.mb@bu3sch.de>
	<1163749589.5826.5.camel@localhost.localdomain>
	<1163750030.4047.1.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Paul TBBle Hampson <Paul.Hampson-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>,
	linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>,
	bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
In-Reply-To: <1163750030.4047.1.camel@ux156>
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

On Fri, 2006-11-17 at 08:53 +0100, Johannes Berg wrote:
> On Fri, 2006-11-17 at 18:46 +1100, Benjamin Herrenschmidt wrote:
> 
> > So what is the solution for Apple machines owner who only get a v3
> > firmware from Apple ? I remember you telling me the answer on irc but I
> > wanted to make it public :-) Some web site we can d/l the windows
> > updates and extract the FW ?
> 
> Yes, fwcutter comes with a huge list of URLs for both firmware versions
> (I suppose they'll remove the v3 ones now...)

Well, the latest "released" version (fwcutter-005) contains a huge list
of ... v3 URLs :-) Only 2 v4 in there. I'll check SVN.

Cheers,
Ben.
