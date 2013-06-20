From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: Problems in bridge.8, ip-netns.8, ip-maddress.8, ip-tunnel.8,
 ip-route.8, ip-neighbour.8, ip-rule.8
Date: Thu, 20 Jun 2013 16:05:25 -0700
Message-ID: <20130620160525.33e78030@nehalam.linuxnetplumber.net>
References: <20130618051405.06917417E7@snark.thyrsus.com>
	<20130619175357.1af033aa@nehalam.linuxnetplumber.net>
	<20130620192944.GA7832@thyrsus.com>
	<20130620213536.GI2124@breakpoint.cc>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA256;
 boundary="Sig_/QZarnuS_xgM2GZb_7p=rc4l"; protocol="application/pgp-signature"
Cc: "Eric S. Raymond" <esr@thyrsus.com>, netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f45.google.com ([209.85.160.45]:36572 "EHLO
	mail-pb0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965679Ab3FTXF3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jun 2013 19:05:29 -0400
Received: by mail-pb0-f45.google.com with SMTP id mc8so6824097pbc.18
        for <netdev@vger.kernel.org>; Thu, 20 Jun 2013 16:05:29 -0700 (PDT)
In-Reply-To: <20130620213536.GI2124@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Sig_/QZarnuS_xgM2GZb_7p=rc4l
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Thu, 20 Jun 2013 23:35:36 +0200
Florian Westphal <fw@strlen.de> wrote:

> Eric S. Raymond <esr@thyrsus.com> wrote:
> > Is this the right repository? If not, where do I find it?
>=20
> git clone git://git.kernel.org/pub/scm/linux/kernel/git/shemminger/iprout=
e2.git

Correct:
 * the master branch is for changes for 3.10 version
 * the net-next-3.10 corresponds to changes for net-next (going into 3.11)

--Sig_/QZarnuS_xgM2GZb_7p=rc4l
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJRw4q1AAoJEICnf2CVzeR+IsIP/0Ki9qD/Nv2cBrl1iG9j9Fkg
UzKcROyCiLbi0C4xE09vo/3XsWyB317wyavYvk/nyRmAJWobzEqYxkazynw/Rp3T
WoK055OGYRwSzXp5Yo/ibhz4FDoYTHD0i7WoRCja//nET/8vD+ddh/Y7i+mq6Yy4
btF+hmo/Km/ZH5zv7J1/4L0FPx1PUBeUGLqyeyK23IKBfTAEn2lsBMuU76BFGkRf
xrPJniStFYXbQQdVXskUg66/T5G5+IhuddaGnrg6DB5PsO3cEibHBapmLhlFC5HT
8N+Jka2sbdf5FhXRIMkQ9dotFd/WjFgynRHTzMx4rViPfk4wYUAJ7CjwK9hSvJDC
uuUO5n+SNEtUR6bN88h64Iy/U+n06BuTyT2LL5JY2KUXohIYj4cSfKLq/V4RdVHz
GIfRuL0G0F0NEOsWb7ikfzswXvivTcmYm+MIyX4w0flDhmXFzLkB8sF4ayML2tNL
o26BVBrvmC1pvfj+6vogKj88lFdUhP4Y/7MFABJWH1pIzEJrYHT8ZBq7Yzw1N5eO
CWoMEDaRfx8kdOv7j5+SHTSSimdrZqh1ZgkGTHVtv3pZus9WbhYKwxi6dodYRIKY
VenHaqJXnw/YBkyK5nUZt/8igqGsTjZdz84BaKDEMfXYbdL3pVV/GtQZw9DQATvj
x7VkqSinZl6h6WozSvAi
=LlhG
-----END PGP SIGNATURE-----

--Sig_/QZarnuS_xgM2GZb_7p=rc4l--
