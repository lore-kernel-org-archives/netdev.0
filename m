From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net-next-2.6 v4] can: Topcliff: PCH_CAN driver: Add
	Flow control/Fix Endianess issue/Separate IF register/Enumerate LEC
	macro/Move MSI processing/Use BIT(X)/Change Message Object index/Add
	prefix PCH_
Date: Tue, 16 Nov 2010 12:43:25 -0800 (PST)
Message-ID: <20101116.124325.116396459.davem@davemloft.net>
References: <4CE275A4.9010400@dsn.okisemi.com>
	<20101116.091443.226753420.davem@davemloft.net>
	<4CE2EC13.9090707@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: andrew.chih.howe.khor-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org, margie.foster-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	yong.y.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, masa-korg-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org,
	kok.howg.ewe-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, chripell-VaTbYqLCNhc@public.gmane.org, joel.clark-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	qi.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4CE2EC13.9090707-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
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

From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Date: Tue, 16 Nov 2010 21:39:47 +0100

> Please take into account that this patch got accepted by accident
> (because the maintainer did not respond properly in time). At that time
> the driver was incomplete, not ready for mainline and did not even work
> properly. Therefore it makes little sense to debug or even bisec these
> changes. Just for that reason I made an exemption and added my
> "Acked-by". Hope you can share my arguments.

You don't put stupid on top of stupid and justify the latter using
the former.
