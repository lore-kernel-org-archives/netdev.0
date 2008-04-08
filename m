From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net-2.6 0/4 (was 0/3)]: TCP fixes
Date: Tue, 08 Apr 2008 02:40:41 -0700 (PDT)
Message-ID: <20080408.024041.190167032.davem@davemloft.net>
References: <1207569344-19687-1-git-send-email-ilpo.jarvinen@helsinki.fi>
	<Pine.LNX.4.64.0804080050060.20948@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	akpm@linux-foundation.org, rjw@sisk.pl, robbat2@gentoo.org,
	gf@unixsol.org, kernel@nn7.de, denys@visp.net.lb,
	alessandro.suardi@gmail.com
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44044
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752999AbYDHJkl convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Apr 2008 05:40:41 -0400
In-Reply-To: <Pine.LNX.4.64.0804080050060.20948@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Tue, 8 Apr 2008 00:59:45 +0300 (EEST)

> On Mon, 7 Apr 2008, Ilpo J=E4rvinen wrote:
>=20
> > Ok, here's the v2 series=20
>=20
> [...snip...]
>=20
> > ...So far, they're just compile tested. I'll see if I find some tim=
e
> > to boot them on the evening.
>=20
> $ uptime
>  00:53:23 up  1:20,  6 users,  load average: 0.54, 0.22, 0.13
>=20
> ...some torrent & browsing, mainly with tso & tcp_sack =3D 0. Didn't =
hit=20
> any problems with it (I had my debug patch in as well).

I've applied all four patches to net-2.6 and will push them
to Linus when I get a chance.

Thanks!
