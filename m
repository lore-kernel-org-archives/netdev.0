From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [net 3/6] can: Fix FSF address in file headers
Date: Fri, 06 Dec 2013 15:42:11 +0100
Message-ID: <52A1E243.9080004@pengutronix.de>
References: <1386340128-23397-1-git-send-email-jeffrey.t.kirsher@intel.com> <1386340128-23397-3-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="XhrBMndkXG0mVIMsHtE8qlmMdK357rpML"
Cc: davem@davemloft.net, netdev@vger.kernel.org, gospo@redhat.com,
	sassmann@redhat.com, Wolfgang Grandegger <wg@grandegger.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:60976 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757987Ab3LFOmb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Dec 2013 09:42:31 -0500
In-Reply-To: <1386340128-23397-3-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--XhrBMndkXG0mVIMsHtE8qlmMdK357rpML
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 12/06/2013 03:28 PM, Jeff Kirsher wrote:
> Several files refer to an old address for the Free Software Foundation
> in the file header comment.  Resolve by replacing the address with
> the URL <http://www.gnu.org/licenses/> so that we do not have to keep
> updating the header comments anytime the address changes.
>=20
> CC: Wolfgang Grandegger <wg@grandegger.com>
> CC: Marc Kleine-Budde <mkl@pengutronix.de>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Tnx, applied to can-next.

Mar

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--XhrBMndkXG0mVIMsHtE8qlmMdK357rpML
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlKh4kQACgkQjTAFq1RaXHPN7gCfcddT2XRDX3MIXCEZWOWjOvbt
OV0AniUw0b4tPM+oiUcD/OsQ5CMDGqQG
=/DXn
-----END PGP SIGNATURE-----

--XhrBMndkXG0mVIMsHtE8qlmMdK357rpML--
