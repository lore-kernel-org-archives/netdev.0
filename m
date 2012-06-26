From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net] ixgbe: Do not pad FCoE frames as this can cause issues
 with FCoE DDP
Date: Tue, 26 Jun 2012 00:53:58 -0700
Message-ID: <1340697238.2255.20.camel@jtkirshe-mobl>
References: <1340696951-2686-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <20120626.005029.909254566674577767.davem@davemloft.net>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-SYSjiCQqoMTcPWeeeMn1"
Cc: alexander.h.duyck@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com, stable@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:13454 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754696Ab2FZHx7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Jun 2012 03:53:59 -0400
In-Reply-To: <20120626.005029.909254566674577767.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-SYSjiCQqoMTcPWeeeMn1
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2012-06-26 at 00:50 -0700, David Miller wrote:
> Sorry, quotes don't work either, what you did is still a SMTP syntax erro=
r,
> here's what is in the bounce I get back:
>=20
> 	<stable@vger.kernel.org> "[3.4]",
> 	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Illegal-Object:	Syntax error in Cc: address found on vger.kernel.org:
> 	Cc:	<stable@vger.kernel.org>"[3.4]"
> 						^-missing end of address

Grrr...

I will re-send without the "[3.4]", Greg will just have to deal with it.

--=-SYSjiCQqoMTcPWeeeMn1
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJP6WqWAAoJEOVv75VaS+3OUrEP/iphu4VfviaRBCXKHujTjiaP
RYasLYHqomrcU35s2nOxstHjpIl2qRmaVSvICNYs6ThGBI8aVj7lzwnNMD/hk4EH
UaJo27+8ksRDzSeKYejtQ6Ilh22onAOQrq8/KTuDk3w8oncRb7ShVydl2JZN9btB
iybp+N9Y9j9xi7Pq3pwNT53eeiPWuvlqXeCLslytOmCnv54r9lK9S5Iqdj36nleV
LxTF28e63h+zKAxIG1IZQVPy/p4UdVuRZ+BD74swpZS559+s1OLzmPsjRsnpfDTX
OzcvYOXsWelgQq5lXvmprbXX7POJtc3naEeK1jWT2+G00i22ddYWzXBDl8AAMqi0
XPFjtVzc+WaRnL0kOlaxwkoYW5qKzEvPHUl1Zyi3Nl0DX0jMJ0ehMryut5LxWH2p
oyuUkL0OwvG5fhYFDBqvMtbvKjYp60UeieUqLHIavzDPgvyxY5yVOO7IJiXoGycv
PmE865LO6y3KRuFLu/oE66ST400uGgKuUBSx0pmVmZJr41dfEBEUuKtVyTvl3Q6j
aFAmpi3VuzHdUO2deqI4AjeYRZBjgKOncvq8RZzHJLgpnFoJdAo4ookljiSA0pYy
6Ab6VqgU8QHAjfom5uQZ14hj5GmWkzyxLe2We++GIz3M/kEI9tlsMoB1gPsv2NNf
HoV/WGvtmfUCRPxpNCD3
=Px7u
-----END PGP SIGNATURE-----

--=-SYSjiCQqoMTcPWeeeMn1--
