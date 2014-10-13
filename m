From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: Regarding tx-nocache-copy in the Sheevaplug
Date: Mon, 13 Oct 2014 16:21:56 +0200
Message-ID: <20141013142156.GE26864@lunn.ch>
References: <20141013105246.GD1972@vicerveza.homeunix.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Carles =?iso-8859-1?Q?Pag=E8s?= <page@cubata.homelinux.net>,
	linux-arm-kernel@lists.infradead.org
To: =?iso-8859-1?Q?Llu=EDs?= Batlle i Rossell <viric@viric.name>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:37844 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752509AbaJMOWb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Oct 2014 10:22:31 -0400
Content-Disposition: inline
In-Reply-To: <20141013105246.GD1972@vicerveza.homeunix.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 13, 2014 at 12:52:46PM +0200, Llu=EDs Batlle i Rossell wrot=
e:
> Hello,
>=20
> on the 7th of January 2014 ths patch was applied:
> https://lkml.org/lkml/2014/1/7/307
>=20
> [PATCH v2] net: Do not enable tx-nocache-copy by default
>        =20
> In the Sheevaplug (ARM Feroceon 88FR131 from Marvell) this made packe=
ts to be
> sent corrupted. I think this machine has something special about the =
cache.

Hi Llu=EDs

Please could you describe your test setup. I would like to try to
reproduce the problem. I have a machine based on kirkwood 6282 and the
same ethernet.

Thanks
	Andrew
