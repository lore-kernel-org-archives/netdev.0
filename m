From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Bonding/LACP on RTL8169sc/8110sc (R1869)
Date: Wed, 13 Apr 2011 19:28:37 +0100
Message-ID: <1302719317.2873.5.camel@bwh-desktop>
References: <4DA45518.60407@navigue.com> <13118.1302648465@death>
	 <20110413174943.GD17579@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Jonathan Thibault <jonathan@navigue.com>,
	netdev@vger.kernel.org
To: =?ISO-8859-1?Q?Fran=E7ois?= Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:39225 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755893Ab1DMS2l convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Apr 2011 14:28:41 -0400
In-Reply-To: <20110413174943.GD17579@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-04-13 at 19:49 +0200, Fran=C3=A7ois Romieu wrote:
> On Tue, Apr 12, 2011 at 03:47:45PM -0700, Jay Vosburgh wrote:
> > Jonathan Thibault <jonathan@navigue.com> wrote:
> [2.6.32.old]
> > 	That's a fairly old kernel; one relatively recent fix that comes
> > to mind is:
>=20
> The r8169 driver has undergone some multicast fixes since 2.6.32 as w=
ell.
>=20
> If I remember correctly, the old 8169 - not the 8168 - was hit.
>=20
> Upgrading is really suggested.

If you mean the changes to register writes (commits
78f1cd02457252e1ffbc6caa44a17424a45286b8 and
908ba2bfd22253f26fa910cd855e4ccffb1467d0), those went into 2.6.32.y.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

