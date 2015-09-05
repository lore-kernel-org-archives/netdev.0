From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: parsing the output of ethtool programmatically
Date: Sat, 05 Sep 2015 10:53:14 +0100
Message-ID: <1441446794.13323.8.camel@decadent.org.uk>
References: <558B5937.4080600@unix-beratung.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-NSuC/ZiFCjWRv/T8nx3V"
To: Robert Urban <urban@unix-beratung.de>, bwh@kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:45416 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754126AbbIEKlk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Sep 2015 06:41:40 -0400
In-Reply-To: <558B5937.4080600@unix-beratung.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-NSuC/ZiFCjWRv/T8nx3V
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2015-06-25 at 03:28 +0200, Robert Urban wrote:
> Hello,
>=20
> there doesn't seem to be any flag to request ethtool to present its outpu=
t in a
> script-friendly form.  Things like:
> >         Link partner advertised link modes:  10baseT/Half 10baseT/Full
> >                                              100baseT/Half 100baseT/Ful=
l
> >                                              1000baseT/Full
> are kind of pain to parse.
>=20
> Something to consider?

Or write a library for using SIOCETHTOOL.  The interface is fairly well
documented now and there are other users besides the ethtool utility.

Ben.

--=20
Ben Hutchings
friends: People who know you well, but like you anyway.


--=-NSuC/ZiFCjWRv/T8nx3V
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAVeq7iue/yOyVhhEJAQpPeBAAtK1fpLnE6NJRXuwW5/eKjYwZrqxgH4Hd
OUA+LD7LymZPAQjQk2TQ8a+Unlxkwz2p30v5qW9dTKO5SN3s3Wfh98kRNQ2/2jDa
Xoa7aj7dHwwDYw+rij7QlL0UBxq8Zz0iiORE8EiLB3DMAiERxRoE7IZPMY5CpHbs
sH5Wsn84IXZf0bWXjJ8HaVJwvr8CM6iHhSvvfW/mhWOLpFkPs+YWasvysFiDDhGB
6eC9Nd6WAY3D5q2s5OEJQ7ZEhLnC5gdDJ73s6fMh+NK5twD66Ip5uZT5CKmItyQh
T85xPCChwjTYUQbnXCRXBqUsef75VCCdH0tEjHE+eh6Bf9RE0QpJvVWMoxdGLQZD
NCVK7sMzjjj/Z6cG2Y5seyOrg4q2PqiLFjslBaYwV+p6djzr0ENMcOWF5FC3PiBk
1uTewYrnKnAYa21DihjAIEvmlM8QsDxpgMYtHpJmqpZa37s+8xL14cuO47zax9fJ
vxOnWW5wnwxI+XuKYGp0B5fVYEjdnsKqJk+8l8YwXWHuaEMwZDbNk3JzTrZg7d62
IDJd07XM3c2oc4tH1XbUd/P69FZHJl8W875cp/A0fseFWIhUMfTTDdBnPJ8owFnu
SjS+m4Anco7WPL+IAG3wKZsoQex7WwNg2e1iL9QQfzCVsZ3q6DigER5RznUEgXqM
w3z7493gsoY=
=foyU
-----END PGP SIGNATURE-----

--=-NSuC/ZiFCjWRv/T8nx3V--
