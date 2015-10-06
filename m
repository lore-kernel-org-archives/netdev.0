From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH 12/12] [RFC] can: avoid using timeval for uapi
Date: Tue, 6 Oct 2015 11:37:01 +0200
Message-ID: <5613963D.9000800@pengutronix.de>
References: <1443612402-3000775-1-git-send-email-arnd@arndb.de>
 <7548522.iLToS4O3HD@wuerfel> <56138EDC.8080501@pengutronix.de>
 <6130832.516TFPqmA3@wuerfel>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="IM5srnSLincitssfHWFxwh8p6sa94CoMV"
Cc: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	y2038-cunTk1MwBs8s++Sfvej+rw@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linux-can-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <6130832.516TFPqmA3@wuerfel>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--IM5srnSLincitssfHWFxwh8p6sa94CoMV
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 10/06/2015 11:18 AM, Arnd Bergmann wrote:
>> Acked-by: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
>>
>> add upstream the 2038 fixes as a block.
>=20
> Davem already picked up the first 10 of the series. If you don't
> mind, I'd prefer if you could take this one into your tree so I
> have it off my list.
> I have 200 other patches in various states and more getting added.

Ok. Consider it done.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--IM5srnSLincitssfHWFxwh8p6sa94CoMV
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJWE5Y9AAoJEP5prqPJtc/HDycH/1tYIXegpWLYJKZhmlWG7gZg
LSzMH5XvIRU20bWbEkcuY1oq60+49W5C5gbKb47oCRAYDOj0kY0IIuXtceAad7SZ
d2cVzX5GUkDTIkKroTaSeIOda9y+0uklbVNBleUpq9ZZMD++wTRZ2MATFW3Y24un
tO5xQHpe6Zg/rmmk0wy3jfbh3Eqllbe8BdFj761sezLh5L16taa5W0X8J+I3uAPA
oJIEItM+nMrQeAcx1cX6B8wGuf0/WmUQ78i5gfqknMZboHLNalhOtRQY1HsMKfKb
zIdY7qMxT3oTrFhUlpMlU/NlgoZMcye/Jj6LoAztxHM24JtwkSztJ3s0UD3p9bI=
=vjai
-----END PGP SIGNATURE-----

--IM5srnSLincitssfHWFxwh8p6sa94CoMV--
