From: Heiko =?ISO-8859-1?Q?St=FCbner?= <heiko@sntech.de>
Subject: Re: [PATCH v3 0/6] support GMAC driver for RK3288
Date: Sat, 03 Jan 2015 23:27:18 +0100
Message-ID: <3223311.vXMaSqpKME@phil>
References: <1419846152-14531-1-git-send-email-roger.chen@rock-chips.com> <1493383.y3pPThNXY3@phil> <20150101.210122.660970681208198668.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: roger.chen@rock-chips.com, peppe.cavallaro@st.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-rockchip@lists.infradead.org, kever.yang@rock-chips.com,
	eddie.cai@rock-chips.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150101.210122.660970681208198668.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Donnerstag, 1. Januar 2015, 21:01:22 schrieb David Miller:
> From: Heiko St=FCbner <heiko@sntech.de>
> Date: Thu, 01 Jan 2015 03:06:31 +0100
>=20
> > Hi David,
> >=20
> > Am Mittwoch, 31. Dezember 2014, 19:15:38 schrieb David Miller:
> >> From: Roger Chen <roger.chen@rock-chips.com>
> >> Date: Mon, 29 Dec 2014 17:42:32 +0800
> >>=20
> >> > Roger Chen (6):
> >> >   patch1: add driver for Rockchip RK3288 SoCs integrated GMAC
> >> >   patch2: define clock ID used for GMAC
> >> >   patch3: modify CRU config for Rockchip RK3288 SoCs integrated =
GMAC
> >> >   patch4: dts: rockchip: add gmac info for rk3288
> >> >   patch5: dts: rockchip: enable gmac on RK3288 evb board
> >> >   patch6: add document for Rockchip RK3288 GMAC
> >> >=20
> >> > Tested on rk3288 evb board:
> >> > Execute the following command to enable ethernet,
> >> > set local IP and ping a remote host.
> >> >=20
> >> > busybox ifconfig eth0 up
> >> > busybox ifconfig eth0 192.168.1.111
> >> > ping 192.168.1.1
> >>=20
> >> Series applied to net-next, thanks.
> >=20
> > could we split this up a bit instead?
>=20
> Too late, what's in my tree is in the permanent commit history
> and cannot be deleted.

ok no problem ... I'll work around it then so that any possible conflic=
ts are=20
easily solvable.


Heiko
