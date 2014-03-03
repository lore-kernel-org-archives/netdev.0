From: Maxime Ripard <maxime.ripard@free-electrons.com>
Subject: Re: [PATCH 1/2] ethernet: sun4i: Drop the older compatibles
Date: Mon, 3 Mar 2014 11:36:33 +0100
Message-ID: <20140303103633.GT607@lukather>
References: <1391806672-27846-1-git-send-email-maxime.ripard@free-electrons.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="GTZ+2qEBTXdGs1w1"
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:33835 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753114AbaCCKkN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2014 05:40:13 -0500
Content-Disposition: inline
In-Reply-To: <1391806672-27846-1-git-send-email-maxime.ripard@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--GTZ+2qEBTXdGs1w1
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Feb 07, 2014 at 09:57:51PM +0100, Maxime Ripard wrote:
> The DT maintainers said it was OK to remove the older compatible pattern,=
 since
> we are still a moving target, users will have to update their DT either w=
ay.
>=20
> Drop the older ethernet compatibles, to avoid maintaining legacy compatib=
les.
>=20
> Signed-off-by: Maxime Ripard <maxime.ripard@free-electrons.com>

Ping?

--=20
Maxime Ripard, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com

--GTZ+2qEBTXdGs1w1
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)

iQIcBAEBAgAGBQJTFFsxAAoJEBx+YmzsjxAgrkMQAJQeqQQcZfFeISlDbPFK4jNp
Zntq94ut2dJFNvwuhed0qasRdvDj8tio5tH+wXcVwTQK3FFEdNLCohNAWUKgIOQu
Knrlcbwf3jxlLAAxU7xN8woOmuZVzHJblyQL3lFoSTQEpjkY/xcXEVfmSct0uwTA
z/MR5uJy9YVXgbO4LejPhhM/qNPKH6b/rFq/awlUTBseVlw6Tt/PCeoyivdWIQAB
44IDFjeFktJK23gHE/cyKxesG85y5yn4NIWnzgEpIBSPgTFUuMTNfvOwD+xz7X/U
MdiJRHhLv8teD8pHCZ33KoUXqthMX8R6S4mthOEIus/Uf0ELqqm2vifZ3Ts43ebK
rUD1ggpAk+QlIyqNqj6BtHcJNIUzKYMz2zCNCFz/iVOz9Bn1+78nbiqDOILNg9Bp
KP16R+Yx8ISXbCxXG8/Ei+sjldRDDCmtihHUt64vO+D6gTdGvJwglJVrpDAY8xZF
EsW2Tu4I0Bdgco0HHMcbtmAR7+fZhNDq18rov25qMFhPvNZiLZBxV3Ed2OA5Z+rh
Iy5Q8fke//kEXhB/3c9jZiR4Kx40+0pUHSLL/aCPYnnm/vt3hTkVzkQUvsEoVP9g
g7eYKCiClxQN/9Iz6ibwj9joPsoU0XCt57ey4M4px2gg7CJpwttzrGuMLMAg5zPp
dahF3EsolqmowNMeorS4
=hNBg
-----END PGP SIGNATURE-----

--GTZ+2qEBTXdGs1w1--
