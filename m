From: =?UTF-8?Q?Andreas_F=c3=a4rber?= <afaerber@suse.de>
Subject: Re: [PATCH v3 0/8] arm64: rockchip: Initial GeekBox enablement
Date: Mon, 7 Mar 2016 13:17:54 +0100
Message-ID: <56DD7172.4000707@suse.de>
References: <1457294038-14243-1-git-send-email-afaerber@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: devicetree@vger.kernel.org,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Heiko Stuebner <heiko@sntech.de>,
	LAKML <linux-arm-kernel@lists.infradead.org>
To: linux-rockchip@lists.infradead.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:51285 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750836AbcCGMR5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Mar 2016 07:17:57 -0500
In-Reply-To: <1457294038-14243-1-git-send-email-afaerber@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 06.03.2016 um 20:53 schrieb Andreas F=C3=A4rber:
> On next-20160304 the GMAC seems to have regressed, it no longer finds=
 the PHY:
>=20
> libphy: PHY stmmac-0:ffffffff not found
> eth0: Could not attach to PHY
> stmmac_open: Cannot attach to PHY (error: -19)

Still with us in next-20160307. CC'ing stmmac maintainers.

http://git.kernel.org/cgit/linux/kernel/git/next/linux-next.git/log/dri=
vers/net/ethernet/stmicro

Regards,
Andreas

--=20
SUSE Linux GmbH, Maxfeldstr. 5, 90409 N=C3=BCrnberg, Germany
GF: Felix Imend=C3=B6rffer, Jane Smithard, Graham Norton; HRB 21284 (AG=
 N=C3=BCrnberg)
