From: Shawn Guo <shawn.guo@linaro.org>
Subject: Re: [PATCH 3/3] net: fec: add phy-reset-interval for device tree
 probe
Date: Tue, 26 Jun 2012 19:15:37 +0800
Message-ID: <20120626111535.GB8858@S2101-09.ap.freescale.net>
References: <1340700308-8315-1-git-send-email-shawn.guo@linaro.org>
 <1340700308-8315-4-git-send-email-shawn.guo@linaro.org>
 <20457.31943.332545.171232@ipc1.ka-ro>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>
To: Lothar =?iso-8859-1?Q?Wa=DFmann?= <LW@KARO-electronics.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe002.messaging.microsoft.com ([216.32.180.12]:7247 "EHLO
	va3outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754204Ab2FZLPb convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Jun 2012 07:15:31 -0400
Content-Disposition: inline
In-Reply-To: <20457.31943.332545.171232@ipc1.ka-ro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 26, 2012 at 11:11:35AM +0200, Lothar Wa=DFmann wrote:
> Hi,
>=20
> Shawn Guo writes:
> > Different boards may require different phy reset interval time.  Ad=
d
> > property phy-reset-interval for device tree probe, so that the boar=
ds
> > that need a longer interval time can specify it in their device tre=
e.
> >
> 'phy-reset-duration' would be a more appropriate name.
>=20
Ok, point taken.  Thanks.

--=20
Regards,
Shawn
