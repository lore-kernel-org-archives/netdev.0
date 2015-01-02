From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 0/6] support GMAC driver for RK3288
Date: Thu, 01 Jan 2015 21:01:22 -0500 (EST)
Message-ID: <20150101.210122.660970681208198668.davem@davemloft.net>
References: <1419846152-14531-1-git-send-email-roger.chen@rock-chips.com>
	<20141231.191538.585375391107637966.davem@davemloft.net>
	<1493383.y3pPThNXY3@phil>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: roger.chen@rock-chips.com, peppe.cavallaro@st.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-rockchip@lists.infradead.org, kever.yang@rock-chips.com,
	eddie.cai@rock-chips.com
To: heiko@sntech.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36789 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751522AbbABCB1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Jan 2015 21:01:27 -0500
In-Reply-To: <1493383.y3pPThNXY3@phil>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Heiko St=FCbner <heiko@sntech.de>
Date: Thu, 01 Jan 2015 03:06:31 +0100

> Hi David,
>=20
> Am Mittwoch, 31. Dezember 2014, 19:15:38 schrieb David Miller:
>> From: Roger Chen <roger.chen@rock-chips.com>
>> Date: Mon, 29 Dec 2014 17:42:32 +0800
>>=20
>> > Roger Chen (6):
>> >   patch1: add driver for Rockchip RK3288 SoCs integrated GMAC
>> >   patch2: define clock ID used for GMAC
>> >   patch3: modify CRU config for Rockchip RK3288 SoCs integrated GM=
AC
>> >   patch4: dts: rockchip: add gmac info for rk3288
>> >   patch5: dts: rockchip: enable gmac on RK3288 evb board
>> >   patch6: add document for Rockchip RK3288 GMAC
>> >=20
>> > Tested on rk3288 evb board:
>> > Execute the following command to enable ethernet,
>> > set local IP and ping a remote host.
>> >=20
>> > busybox ifconfig eth0 up
>> > busybox ifconfig eth0 192.168.1.111
>> > ping 192.168.1.1
>>=20
>> Series applied to net-next, thanks.
>=20
> could we split this up a bit instead?

Too late, what's in my tree is in the permanent commit history
and cannot be deleted.
