From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH]: bcm43xx-d80211: fix hwcrypto issues (mcast)
Date: Fri, 17 Nov 2006 12:04:42 +0100
Message-ID: <1163761482.4047.4.camel@ux156>
References: <ej09qf$2nv$1@sea.gmane.org> <200611120934.28133.mb@bu3sch.de>
	<20061114142959.GA17486@keitarou> <200611161507.33971.mb@bu3sch.de>
	<1163749589.5826.5.camel@localhost.localdomain>
	<1163750030.4047.1.camel@ux156>
	<1163750573.5826.7.camel@localhost.localdomain>
	<jeveles6lx.fsf@sykes.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Benjamin Herrenschmidt <benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org,
	Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Martin Langer <martin-langer-Mmb7MZpHnFY@public.gmane.org>,
	Paul TBBle Hampson <Paul.Hampson-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>, bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: Andreas Schwab <schwab-l3A5Bk7waGM@public.gmane.org>
In-Reply-To: <jeveles6lx.fsf-+JVCjXrnBTholqkO4TVVkw@public.gmane.org>
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

On Fri, 2006-11-17 at 11:35 +0100, Andreas Schwab wrote:

> Still the same.  One of them does not exist, the other one requires
> Javascript!

Yeah, looks like Martin forgot to put the URLs in the the readme while
he put them into commit messages...

Try these:

Support for bcmwl5.sys v4.80.53.0 added.
ftp://downloads.netgear.com/files/wn511b_sw_3_28_3_8_setup.zip
(bcmwl5.sys is renamed to wn511b.sys)

Support for bcmwl5(64).sys v4.100.15.5 added.
from the latest Linksys WPC300N driver at
http://www.linksys.com/download/
It's ucode revision 0x0173, patchlevel 0x0425, 2006-10-04.

Martin, can you add these to the readme?

johannes
