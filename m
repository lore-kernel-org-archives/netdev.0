From: Heiko =?ISO-8859-1?Q?St=FCbner?= <heiko@sntech.de>
Subject: Re: [PATCH v3 0/8] arm64: rockchip: Initial GeekBox enablement
Date: Mon, 07 Mar 2016 13:24:25 +0100
Message-ID: <2714888.1DdqvJZ8cb@diego>
References: <1457294038-14243-1-git-send-email-afaerber@suse.de> <56DD7172.4000707@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-rockchip@lists.infradead.org, netdev@vger.kernel.org,
	devicetree@vger.kernel.org,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	LAKML <linux-arm-kernel@lists.infradead.org>
To: Andreas =?ISO-8859-1?Q?F=E4rber?= <afaerber@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gloria.sntech.de ([95.129.55.99]:55172 "EHLO gloria.sntech.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750836AbcCGMYa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 07:24:30 -0500
In-Reply-To: <56DD7172.4000707@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andreas,

Am Montag, 7. M=E4rz 2016, 13:17:54 schrieb Andreas F=E4rber:
> Am 06.03.2016 um 20:53 schrieb Andreas F=E4rber:
> > On next-20160304 the GMAC seems to have regressed, it no longer fin=
ds the
> > PHY:
> >=20
> > libphy: PHY stmmac-0:ffffffff not found
> > eth0: Could not attach to PHY
> > stmmac_open: Cannot attach to PHY (error: -19)
>=20
> Still with us in next-20160307. CC'ing stmmac maintainers.

do you remember from what revision you rebased away from, when it was s=
till=20
working (as a known-good state)?


Heiko

>=20
> http://git.kernel.org/cgit/linux/kernel/git/next/linux-next.git/log/d=
rivers/
> net/ethernet/stmicro
>=20
> Regards,
> Andreas
