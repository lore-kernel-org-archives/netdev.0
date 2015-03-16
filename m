From: Kenyon Ralph <kenyon@kenyonralph.com>
Subject: Re: iproute2 documentation
Date: Mon, 16 Mar 2015 08:31:57 -0700
Message-ID: <20150316153157.GF26326@kenyonralph.com>
References: <1988820225.2425618.1426503091224.JavaMail.zimbra@redhat.com>
 <486332040.2425794.1426503272511.JavaMail.zimbra@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
	protocol="application/pgp-signature"; boundary="CblX+4bnyfN0pR09"
Cc: netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Pavel Simerda <psimerda@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from darwin.kenyonralph.com ([173.255.215.209]:52024 "EHLO
	darwin.kenyonralph.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934443AbbCPPhS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2015 11:37:18 -0400
Content-Disposition: inline
In-Reply-To: <486332040.2425794.1426503272511.JavaMail.zimbra@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--CblX+4bnyfN0pR09
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 2015-03-16T06:54:32-0400, Pavel Simerda <psimerda@redhat.com> wrote:
> Hello,
>=20
> I just stepped on your manpage commit that got apparently lost in history=
 as
> the current manpage doesn't for example include the lifetime description.=
 Let
> me know if I should prepare a new documentation patch for the current git=
 master
> or you want to handle it yourself.

Not sure how this would get lost, but please go ahead and keep the
manpage up to date. I'm not a maintainer of it, I just saw that it was
lacking at the time and tried to fix it.

> commit 43d29f782f12d6212ea3717a3a47b0036474a67c
> Author: Kenyon Ralph <kenyon@kenyonralph.com>
> Date:   Thu Mar 15 14:39:12 2012 -0700
>=20
>     Update ip address manual page
>    =20
>     * update synopsis to match "ip address help" output
>     * specify IPv4, since "IP" is ambiguous
>     * remove deprecated site scope
>     * document lifetimes, home, and nodad
>     * update wording to make sense since page was split from the ip(8) pa=
ge
>     * git rid of extra spaces
>=20
> Cheers,
>=20
> Pavel

--=20
Kenyon Ralph

--CblX+4bnyfN0pR09
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCgAGBQJVBvdtAAoJEJj/PvnJuRLVOl0P/14FKV6NxG9yYQa+bm6aZFqZ
x6Ef72xL+rJDw8gxaq9RW8I+HD4+wOcZjiUBe2HtYGnncb7i07JukWbwczlCrm1w
SgC+bOmTl7IUVZ9dowcIU+/Jy/PVu1CklpZXP+vxqK/0ZY3YFvmuej2AlStTheyc
urhbCMil2cKINB5BHZsMGXpUK+p/tc8xOTwHItvzmsk90HUiXDkFAJZE653ODGd8
iHN4o0ViaC4MIURUuD7f2AbZgVtRle/mEKwfOlb3ZraTZqMEqAw4iztsQRHr/9jw
13V2oXLzdJApkBh3cHdpt8JWpHwF4/V0H5E8Yi/5FNQI/8l981B6IvbTu/pp6YlD
ZLX3AqRK7fbD2f5UpwY2FI8K6m35hzt5M+90Vd9Vz+vcBFyCEZbn5sz3ndhan6p+
6lNGO3I76No+DNobgxKOYJ99K9smxsqcL+hEGQ3GMhmKiJVjTMn5j8we1lWJVw4M
63/7RGc3P33+ICN2T8bIcpKzZpVpyXLZyyDUhx32QyzmSeEC4Xp326p4xenNQM5r
rJoZYzrfYRyP4cepKkDONxinJ+AGKMoOZI9UgQmW2uH99O817oNSGxE2OOTbce+a
6jCHKWuEhNodznbHFUKBlogxajxslAGiXgLj9UPW1gvIpU+pwOoC9PnbzTo9ipV3
CRMtmHJFc1x6kgFrcKpM
=O6m4
-----END PGP SIGNATURE-----

--CblX+4bnyfN0pR09--
