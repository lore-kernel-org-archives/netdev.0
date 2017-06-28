From: Michael Grzeschik <mgr@pengutronix.de>
Subject: Re: [GIT PULL] arcnet: fixes and features
Date: Wed, 28 Jun 2017 18:04:05 +0200
Message-ID: <20170628160405.73fdb5etr4cf56dm@pengutronix.de>
References: <20170622153110.4079-1-m.grzeschik@pengutronix.de>
 <20170623.135403.778221185468261150.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="qkqndxsb5amt2r3v"
Cc: netdev@vger.kernel.org, kernel@pengutronix.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:48991 "EHLO
        metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751581AbdF1QEJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Jun 2017 12:04:09 -0400
Content-Disposition: inline
In-Reply-To: <20170623.135403.778221185468261150.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--qkqndxsb5amt2r3v
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On Fri, Jun 23, 2017 at 01:54:03PM -0400, David Miller wrote:
> From: Michael Grzeschik <m.grzeschik@pengutronix.de>
> Date: Thu, 22 Jun 2017 17:31:02 +0200
>=20
> > are available in the git repository at:
> >=20
> >   public@git.pengutronix.de:/mgr/linux.git tags/arcnet-for-mainline
>=20
> I'm not pulling from that address, either setup a properl kernel.org
> GIT account or we work with just plain patches.

Since helpdesk@kernel.org does not seem to respond for
my account request I will resend the series as plain patches.

> Next, you need to provide a proper commit message in a
> "[PATCH 0/N] " posting explaining at a high level what
> the patch series is doing as a unit, how it is doing it,
> and why it is doing it that way.

Will do.

> Finally, in patch #1 the assignment of "flags" to "0" in the
> declaration is unnecessary please remove it.

Fixed that.

Thanks,
Michael

--=20
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |

--qkqndxsb5amt2r3v
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEElXvEUs6VPX6mDPT8C+njFXoeLGQFAllT03EACgkQC+njFXoe
LGTOlQ//Xn2PAi1ScPAijVs9biCjlVYxfferPlbI4GXaYt7Cr8fWFTsSxn/AOUHD
38yYpGbOo2EXz3eP+y0mid6MeqYHESpJP156XkuHvHxPSk4ZhOj5AaM3uYBktOD0
PyBAuAOT3geRPen+Wlez86FUns5zF55k8h8LDyMsj/zbk+HnTulPuoFIVVxAK6MA
Fq2fWVGSS3Dx6u8gn7frU5qhhu7WzSQrrQ46CICcpz8zIVrQ7dDJ/lxGMiVcJE+w
4wsyWJv66qzD4xsn/CUP/ceTrFTy1xT2El+ezhwT69eQdlNq73AXmvju3c0z8Dhs
BAgr4OMF03rkDVbbUfKlTmzRylng1quJFtsAdCutBtgRFDxRhabZpLGGCbQ+yDeg
c5dDAg6R0FikwGM/4zh+kADi01cmKrT5d3yR/WCe61s6eU5MsESQ2DT6XgpZm1kl
XVm2Te/7cO2TTrWqrKPBLeKPD/rSbbzJ/NSHm92gNPR9L6Dlv4/wVc9WMkeEXN5B
mRQfVB6lu5IKOt4xLnU0hysQZjN8khPMai+u5FXFNqJ7i0piWYgCmAEnCk31VDbQ
7aSJSD5aQ93tPctw97Wod/sED7Kk/jPc57K4w0vm+k/7W+fuTVGsegEIKz5jrJqB
MScV27/BFkXmsMAysNrdkhn7qMPt6TzwkBm1KITL1RCEZj/5XMs=
=F4rq
-----END PGP SIGNATURE-----

--qkqndxsb5amt2r3v--
