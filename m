From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 11/13] can: at91_can: use endian agnostic IO accessors
Date: Fri, 20 Mar 2015 10:06:58 +0100
Message-ID: <550BE332.1030901@pengutronix.de>
References: <1426693992-31163-1-git-send-email-ben.dooks@codethink.co.uk> <1426693992-31163-12-git-send-email-ben.dooks@codethink.co.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="u2psDh2VnkxmM78EaS95HQwkv7GbuasmT"
Cc: Wolfgang Grandegger <wg@grandegger.com>, linux-can@vger.kernel.org,
	netdev@vger.kernel.org, Nicolas Ferre <nicolas.ferre@atmel.com>
To: Ben Dooks <ben.dooks@codethink.co.uk>,
	linux-kernel@lists.codethink.co.uk,
	linux-arm-kernel@lists.infradead.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1426693992-31163-12-git-send-email-ben.dooks@codethink.co.uk>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--u2psDh2VnkxmM78EaS95HQwkv7GbuasmT
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 03/18/2015 04:53 PM, Ben Dooks wrote:
> Change __raw accesors to  endian agnostic versions to allow the driver
> to work properly on big endian systems.
>=20
> Signed-off-by: Ben Dooks <ben.dooks@codethink.co.uk>

applied to can-next.

Thanks,
Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |



--u2psDh2VnkxmM78EaS95HQwkv7GbuasmT
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCgAGBQJVC+MyAAoJECte4hHFiupU0/IP/0s8Js3RvaJiZQ099A8xbU05
o9Iv7nieK39575X4g3fPXVrACk/TMYkg+rhoW+PaMgDMWaLRA4BR7cP2DrE55UkB
AzLHOnjY+7jGgdhxgg3Nj14JNQLXo7pL1Nq4z0wfAZfiSxdGszSRZS/glzQcO0AE
NhTl7CxAgFu8WUBWCtLa5AiVU6SrnmDNr6PHQlUnPT/y6FqgkkAjTPdmEf3VFmcI
xqze6ZCSU15D3ULhhGfJ0GUR732T8ALwZE726v3xNY9TrEjhquP7KPgkOdazr+fE
5lJ/cqZSm5oMGSlVuXaKtqKFmA0E8j1yXsi3nyRRojW00YuaJvRL0H3fV+Qmm6CY
p9bEmKeReJnGzvoZ17FZeNsvWFbFoSrxdHk1he7Gw9I0utUlVj/baXADf61ydJqB
EZdoOLUAq4Wsvmr0L9uMFgC58JCcKmWObqVqi1EEV7O06JQg+91OO4/0C3RCAdJC
sB0qH4vxgmWCQaZBtibHVq7UBmOGDZMo9bdTb0dF03ggAfgRqQBLSAaxSybt8nKW
fVnHI9ThgEDVGyDxk3+QFBwDEjj0nu6knAFpVlCsNfIEKzz1dKfCb7K7snTNoTfj
VLWPBSqVPKFIbrobHt0IHDxld61+RNo83wwxoILneEGxyFwXCKZn9KJ4qbN5F96e
Xmej6pncgwiLa8S1efB5
=MNQO
-----END PGP SIGNATURE-----

--u2psDh2VnkxmM78EaS95HQwkv7GbuasmT--
