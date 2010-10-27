From: "Tomoya MORINAGA" <tomoya-linux-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
Subject: Re: [PATCH net-next-2.6 v2] can: Topcliff: PCH_CAN driver: Fix build
	warnings
Date: Wed, 27 Oct 2010 09:50:08 +0900
Message-ID: <00de01cb7570$e88ca730$66f8800a@maildom.okisemi.com>
References: <4CC61B1B.3090602@dsn.okisemi.com>	<20101026.105206.15244527.davem@davemloft.net>
	<20101026.105545.200376685.davem@davemloft.net>
	<4CC71DA4.3020600@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: andrew.chih.howe.khor-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org,
	margie.foster-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	kok.howg.ewe-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, joel.clark-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, yong.y.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	chripell-VaTbYqLCNhc@public.gmane.org, qi.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: "Wolfgang Grandegger" <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>,
	"David Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Wolfgang and Marc,

On Wednesday, October 27, 2010 3:27 AM, Wolfgang Grandegger wrote:
> for the inconvenience, but the original author should have received it.
> Tomoya, could you (or somebody else) please also fix the remaining
> issues quickly?

"masa-korg-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org" left this project. and this mail-address will be deleted soon.
I (tomoya-linux-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org) have taken over "pch can drive" from him.

I will modify your comments ASAP.

---
Hi David,

On Wednesday, October 27, 2010 2:52 AM, David Miller wrote:
> There are still problems.
> 
> This is beyond frustrating.
> 
> > index 55ec324..2889e11 100755
> 
> Why does the pch_can.c file have execute permission in your tree?
> It doesn't in net-next-2.6 and that is what you should be generating
> patches against.
Sorry for the inconvenience.
After updating maintainer's comments and yours, I will post again.

---
Thanks, Tomoya(OKI SEMICONDUCTOR CO., LTD.)
