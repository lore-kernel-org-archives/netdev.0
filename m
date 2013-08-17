From: Antonio Quartulli <ordex@autistici.org>
Subject: Re: pull request net: 2013-08-17
Date: Sat, 17 Aug 2013 12:53:49 +0200
Message-ID: <20130817105348.GA849@ritirata.org>
References: <1376735694-676-1-git-send-email-ordex@autistici.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="6qFdnjy6dKaiDX/E"
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from contumacia.investici.org ([178.255.144.35]:64036 "EHLO
	contumacia.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752633Ab3HQL0M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Aug 2013 07:26:12 -0400
Content-Disposition: inline
In-Reply-To: <1376735694-676-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--6qFdnjy6dKaiDX/E
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sat, Aug 17, 2013 at 12:34:53PM +0200, Antonio Quartulli wrote:
> Hello David,
>=20
> here you have another very small fix intended for net/linux-3.11.
> Tha patch properly closes a seq_read session by adding an invocation to
> skb_abort_seq_read().
>=20
> Please pull or let me know if there is any problem.
>=20
> Also, when do you plan to merge net into net-next? I have a couple of cha=
nges
> for net-next which is better to apply after the merge.

Hi David,

sorry but I just realised there was another small patch to add here.
I'll re-send this pull request in a while.


Regards,

--=20
Antonio Quartulli

=2E.each of us alone is worth nothing..
Ernesto "Che" Guevara

--6qFdnjy6dKaiDX/E
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.20 (GNU/Linux)

iQIcBAEBCAAGBQJSD1Y8AAoJEADl0hg6qKeOIJwP+QGRPMkSC0C1vTiiJa7EJLte
qOb7Qcfi213+c2DuEunyksjjWHNq7RAtbLMZ+43bhFKK/fFDVsEcO14zyXHbzaRR
FlPOC3u4xIVPyKl90msF5YvYOiHsOK971ZQL10Pf0dbXq45/d9Wkm9Y8EMuVyk1y
kcTg0VZp0XR4O/8WGpbv2o2e4NaYixVYLQoZwWTlLhPp+22rCHp0LsyfFB10thS3
Dh9l2b+obYUzx7N9+7IWx0cnhRPVv9OmZFxsAEe8L/UM0EYcY3qtf3ynmOGP8mXS
19+l+xbkTIa9zFoc6xoPaFmBOLNlj+IjjJ79DA3X/LrOK3XyGa/gk2h6Tw/orUfu
cx9HIlTyucsATRyVsTsB1Hpa0dfeCUhFat0nH4NUuMBXJWagGihkw/iTK0Qa7n6v
3x5uBDRo8iF4+S+BAPoH+TM/1iMD46LCYfwjy61Nc/M50PB54VlyMHgB01A+knVR
9fFPCOWpA1hjfBn/CWxjeK68IpRSTZpBTstbA3tM8VMjHizh/8mxTroqMTpw4Y1T
YoQOWzxCKLtlVVKhSfeVR/8YjA8s1+SGff9N2Puqf5mhZHbAcCutUjHPMIiorRxl
UiY9PfTJc727zqMMWhkVoZRWOQt0YRuHoOfKnpqg9asuKrGZ0ew1cRkFODDmn/yQ
O7YHk2L9jzsNm87Zvce/
=DGRl
-----END PGP SIGNATURE-----

--6qFdnjy6dKaiDX/E--
