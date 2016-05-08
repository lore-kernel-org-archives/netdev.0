From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH] Add support for configuring Infiniband GUIDs
Date: Sun, 8 May 2016 07:59:47 +0300
Message-ID: <20160508045947.GP29160@leon.nu>
References: <1462549405-16003-1-git-send-email-eli@mellanox.com>
Reply-To: leon@kernel.org
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="WOTjKnJ88wpJKlWH"
Cc: shemminger@osdl.org, netdev@vger.kernel.org
To: Eli Cohen <eli@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:49844 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750929AbcEHE75 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 May 2016 00:59:57 -0400
Content-Disposition: inline
In-Reply-To: <1462549405-16003-1-git-send-email-eli@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--WOTjKnJ88wpJKlWH
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, May 06, 2016 at 10:43:25AM -0500, Eli Cohen wrote:
> Add two NLA's that allow configuration of Infiniband node or port GUIDs
> by referencing the IPoIB net device set over then physical function. The
> format to be used is as follows:
>=20
> ip link set dev ib0 vf 0 node_guid 00:02:c9:03:00:21:6e:70
> ip link set dev ib0 vf 0 port_guid 00:02:c9:03:00:21:6e:78
>=20
> Issue: 702759
> Change-Id: I5ffb54d6de7bfa8650bf5818f484279914991d6e

These two lines are not needed to be part of commit message.

--WOTjKnJ88wpJKlWH
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJXLsfDAAoJEORje4g2clinlVAP/iDKER7ob/xXs9vNxVkBGSAo
pp0pXmgsLfgZkFmgJzMtiU/Kg9kozZ/bdm0MM1YXcyvvXAUY/aYLzn1aUNg82JKW
ztG+0VVJNYM5papDt9x/u8aK3jrAXAjFulGYK7QGtU1PX+y3Zysrc/dJuQUpWOKi
TaUWmIdNKzITTkaZKoMur8X/T+CkkoSUP6IzQ3PRagNU+h0/P8lZSkyxR8b+tjOv
FVDZAozf8QPYr6JwaSD5k1HlwFMzJwN4H+vdlsED+96UaWyw7uHmyhIDdhnloVXf
NxxGn9KeGaRqPKSrTiz5kFCDtd4lHcUr00sMqsvQSOGeCpq5LrHtBg0Z1TjfLad6
xqwn2NI/gJUiNSL5z7WrXHmOeOsP6J523QKzUyQcKzdf2BU49sxDK9MhmklqMuJY
A/utNAa+jBLeEEuiMq1w9yPxnY05lMB7oYEkeBP6cYuCQSuJT8nQjZzIKTEuroeg
heQRFnNy/7+rWhsUxCaZT12R/upk8vPVkRX26tnPjJ5yS4/MHpZ2LnWKp5tIRaJw
4ynYAns2t6NfATrOIJ9pO32N3oolhekxctABCEhXiyr24VZ6Wdi95lrd8wsurCGS
ozX7xq7AM/AJ3M9EfyqJtadcpknK0COIRvOlXQ4RF+wYgrAKWPt+yejxXwCWtEPb
3UsvtqCxfZVS7ES0TJdE
=7Bto
-----END PGP SIGNATURE-----

--WOTjKnJ88wpJKlWH--
