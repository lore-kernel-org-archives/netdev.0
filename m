From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: New sparse warning in net/mac80211/debugfs_sta.c
Date: Mon, 25 Feb 2008 20:56:43 +0100
Message-ID: <1203969403.13162.147.camel@johannes.berg>
References: <47BDBC23.5080007@trash.net>
	 <20080223.200202.255773165.davem@davemloft.net>
	 <1203933228.13162.58.camel@johannes.berg>
	 <20080225.115220.02432174.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-0SN7MBS3deoIHG6mbT9e"
Cc: kaber@trash.net, joe@perches.com, harvey.harrison@gmail.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:59637 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755414AbYBYT46 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Feb 2008 14:56:58 -0500
In-Reply-To: <20080225.115220.02432174.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-0SN7MBS3deoIHG6mbT9e
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


On Mon, 2008-02-25 at 11:52 -0800, David Miller wrote:
> From: Johannes Berg <johannes@sipsolutions.net>
> Date: Mon, 25 Feb 2008 10:53:48 +0100
>=20
> > Maybe we should just add a new printf modifier like %M for MAC
> > addresses? Then we could use sprintf, snprintf, printk and whatever we
> > please without any of the macro stuff...
>=20
> But GCC has no idea what the heck it is and will warn.

No, I actually wondered about that too and finally just tried, it simply
ignores it when doing the printf warnings.

johannes

--=-0SN7MBS3deoIHG6mbT9e
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUAR8MdeqVg1VMiehFYAQJf7A/+MkD+rPys/GtQSwNfK0aIyG/tMZuRUpQw
AJhUacgetSnoi2klfi3oEwJccsRn090qshTQP1pxf4V7/G0KgcTLIBBSFxxAO4cV
RGmXQadRedlqHTCjHl4a1K7hidwKfkCMsLskh8f9MGlUBPfRSuU1x31/6XG5EH8f
qdngQCLYNLHoBiYQEymNKD6IkAo+6cJPvSI+fWh71Uqd6f/JsCGFTgi80CO/02Fq
HqO7Enx+1g8XGP87v5qNAfI2WMZylDQkj9kMEc/ObtLxGdkmUHNWG5uEc2VOxKFM
fEawai6GiAYS4mYVkfADjBis4GbRrYsfJvU+AdyXwEdvLrZ2UYyaWtYKGeujasZX
DT+Q5v1cJ5dEzfswsjnVAMPuavzvQRH7sFzVfELdIxrssVfZ03ChLVYFI4aS0H9l
N6HxLZaEW2GgbuFYWF2yBiIV2xUCtm12nw6Bg0Ta8Xdtv29jjDM32SbNJIOYEsHU
0mXDUvjujnSkzCuqu0bswWI6deNTRg4NjvEm3ruqaF05HiO9ARiLsNPtzDp7u22J
OIO7R0Y5e0gUS4QtDDcMu7sKGWyihn1qlgvBG5Wlwtn+xkiii3bARvyCd3qN3Ydj
wQ8FsvElsedVe16LTM4q09PfR3RzDIgi96YTZrCZmEBlbox+3vYcYiNRE+WH6sDN
0BABGunw4JE=
=YfZG
-----END PGP SIGNATURE-----

--=-0SN7MBS3deoIHG6mbT9e--

