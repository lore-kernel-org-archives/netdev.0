From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: ipv4: Perform peer validation on cached route lookup.
Date: Mon, 5 Dec 2011 16:31:54 +0300
Message-ID: <20111205133153.GC3374@mwanda>
References: <20111205132714.GA27452@elgon.mountain>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="eHhjakXzOLJAF9wJ"
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet15.oracle.com ([141.146.126.227]:19560 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932250Ab1LENbv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2011 08:31:51 -0500
Content-Disposition: inline
In-Reply-To: <20111205132714.GA27452@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--eHhjakXzOLJAF9wJ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

The continue in __ip_route_output_key() has the same issue as well.

regards,
dan carpenter

--eHhjakXzOLJAF9wJ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJO3MfJAAoJEOnZkXI/YHqRfXUP/A8MF1EH5GSKTruAEhLBi/rT
J9eps6Dnxajqlbv9ci2GwfkFksuNuyvwmtOiUXzZHCM5MaO/fUxP+/UctyfmzoaT
uuKUuaHSiNdCZXMVO59HNTe41gbg+wM9T5RarCDUKLFgye/uahM7LwvVSuV7mnYc
LjMxpt60ZYjtsIR98JVM1pAuKcXEjUFz3dAVk05qZZYeAGyY1QRuNUh0G4/UutVc
3XDtLG1jZgAVQtpeNbLoEk2lhOpri6O3Ag0+KlQLwbuLkGEAwCkj3nqqXRcifpqb
Ufgrb03SWqmLvRtKuIAqvhjW1dvaE4/LA4Lj2p0s1IJq1xOAxkXgecpt/aKiCE1X
/Zt4rOGwG10B+HYvRfXU23gTHJI2x7cnwmVHZzD0nGnr9LgoyPjH8SlVRbGcHTQ6
z1iGnmLKZvDiMm7Wh1d5mdsLE2DGk7oLUJxqJweSsDnjiOOzdE8XPyarrc60HQrr
sxhmKYQIqyaVYLHPlG/xk38B73kt00RYBumWdyZPm4vWlqw8W4EVYnRswHCO6OTX
MxtmkhD2dlSxlub3eb6Jv3cuoqRuQW57dJNP7fF2IlRC4I/mZcvTALP7MPaWkaST
kaXu5EwzGp/mA2kKa17wvFoPITU5NZ6BhMhql2mhVnvFCfMrMlPbr95x11IUTFkm
mJY4uLn9lCiFDsXbwbjZ
=Xwjp
-----END PGP SIGNATURE-----

--eHhjakXzOLJAF9wJ--
