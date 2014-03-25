From: Markus Pargmann <mpa@pengutronix.de>
Subject: Re: [PATCH] net: micrel : ks8851-ml: add vdd-supply support
Date: Tue, 25 Mar 2014 11:06:32 +0100
Message-ID: <20140325100632.GB14810@pengutronix.de>
References: <1395384768-8461-1-git-send-email-nm@ti.com>
 <20140324.003758.1244022408748408267.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="oLBj+sq0vYjzfsbl"
Cc: nm@ti.com, rmk+kernel@arm.linux.org.uk, tony@atomide.com,
	devicetree@vger.kernel.org, netdev@vger.kernel.org,
	linux-omap@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:36106 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751194AbaCYKGz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 06:06:55 -0400
Content-Disposition: inline
In-Reply-To: <20140324.003758.1244022408748408267.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--oLBj+sq0vYjzfsbl
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On Mon, Mar 24, 2014 at 12:37:58AM -0400, David Miller wrote:
> From: Nishanth Menon <nm@ti.com>
> Date: Fri, 21 Mar 2014 01:52:48 -0500
>=20
> > Few platforms use external regulator to keep the ethernet MAC supplied.
> > So, request and enable the regulator for driver functionality.
> >=20
> > Fixes: 66fda75f47dc (regulator: core: Replace direct ops->disable usage)
> > Reported-by: Russell King <rmk+kernel@arm.linux.org.uk>
> > Suggested-by: Markus Pargmann <mpa@pengutronix.de>
> > Signed-off-by: Nishanth Menon <nm@ti.com>
>=20
> Applied, thanks.
>=20

The two regulator patches for enable and disable are going into the
stable trees so this should also be submitted to stable for 3.10 to
3.13.

Regards,

Markus

--=20
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |

--oLBj+sq0vYjzfsbl
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJTMVUoAAoJEEpcgKtcEGQQu7wP/jIk0DjopMZx9a08M3howGoy
qvIvJ6acs8og+jtbWC9LNCm9e3/vS88Ai52H1L3GZTvVQhCbssGkDXSzHclyvIDV
DvJw/pRDNhUe7ByUOhObQzixtZ9ACPbyxWTSoyOz3y/YBQi752uut3KBjCFMXiRV
t2Y3RdtcWDyEXupqSXWAjZ8SjlAD/0lzvOKXPxWVuGtlu+Wz0O2WwN7Oq5aldMt2
QyLDyCt4uPKXtuHgCGfzlK9fDizfDlvZRHauPWkxLoPTNbJQz8QEubviW3bh0YbH
EwOFlUcMbKxYhjAnVbv+hUAFckaByFZZy8WMBJD/oZzFpBpwagqJNkOC4LBcUvLN
VMfFGsHeHMK0QDPWpcf9TMTfMXuTN3PT9OP0Gtjqy2BCpURI1yWQtzck0CYM4nD7
Sq2YxUKevBAFZp23fLfNkqz5O+AxuNWmHigA3gtCGrGf4+V8Ml+bh4LxO15mfI/k
kKJQrDlVqsmIbeX0e9waOD08Dv8/ZsZRiB9nlDXXr7RmrqauUGEQrjKniY/QvAtc
RmAdZC4EC6gIjHBk2hfs/Ky/B2f1/wnhpCDQtVPQQYOR4Jfztw5t6zmmP0MaCIbM
rbBLdEY+wPmptCM5mPGOr1JbQSz+P5kCspP3clYBQEhi1FJyCJoYo7pXcC2PIhs5
4r2F5BHdt43vZLCClh01
=1zLw
-----END PGP SIGNATURE-----

--oLBj+sq0vYjzfsbl--
