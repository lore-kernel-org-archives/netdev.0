From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: Setup of testing lab and work on development
Date: Wed, 15 Nov 2006 22:15:09 +0100
Message-ID: <1163625309.5399.121.camel@johannes.berg>
References: <d9a09df00611150857i3ac7e35cr84dd61cfd55f5b4e@mail.gmail.com>
	 <1163614554.5399.112.camel@johannes.berg>
	 <d9a09df00611151304l11d089b5w958788ec24fc6af0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-/dhhNfUFDGnIA7J/FHP9"
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:49031 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1030749AbWKOVQr
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Nov 2006 16:16:47 -0500
To: Udayan Singh <udayan.singh@gmail.com>
In-Reply-To: <d9a09df00611151304l11d089b5w958788ec24fc6af0@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-/dhhNfUFDGnIA7J/FHP9
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2006-11-16 at 02:34 +0530, Udayan Singh wrote:

> ok. you are referring to bcm43xx , etc

right, all of those drivers use d80211.

> lets say we have development happening in d80211 driver. now if i want
> to participate in the development of the (d80211), i can do it in a
> much better manner if i am trying out modificaitons on my own on the
> drivers that are using d80211 (my feeling)=20

I doubt you'll get far without ever testing your code changes. :)

> e.g. bcm43xx, etc. Hence i
> would like to setup a test environment where i can make modifications
> in code (of d80211 or related driver) and test it....

You'll need one of the cards that is supported by a d80211 driver. I've
used bcm43xx and rt2500usb so far.

> same - "participate in development on d80211"

Well, check http://wireless.sipsolutions.net for things we still have to
do... and then send patches :)

Or do something else you're interested in and send patches.

johannes

--=-/dhhNfUFDGnIA7J/FHP9
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUARVuDW6Vg1VMiehFYAQLvjA//TBCRXGaxEgbF8aDslCwDXmqNd4S3EXrf
OItjeatQLm1LUxBvdOepBErrKJN7wjsNzw1DwQ6AZVcrc2E+amDPseieqPgtcFpH
VKResXTRm6S+2vYItfz/KF9fEAyxJRs/cqUIUm0IM3Wz8rCKE/7J21dI6ArWIX/d
BOA6nKt9+JaZ5Ck4smonyEF7RCotKSL1c1fG3W6VUuAYE6Euf2J9MeJhkjbWKZya
MjVA4COYlOl8rwtkto41KYOBJuwu6Qi5OI/0zHXmHHaZX/Vth/P0k6YWq/xcvtnw
eUMkUG25Kjub80W/DYruetWLw5z/mU2bqjmMdcA+/mOGyvaYluPo35D26CAq1mag
j18X8ZumMywj+V/yXokUgHjt5tZDuf4poLK6zyKMfQEi15RdSPDH1e+qrTk4HTS6
sd9Maw7X1YQET3ATTRpGNlQ7IyeMejH7EdgNPrOZjOoKV40zcVGC2UI4RjH1T4bj
NH+BXrdrAM2e/ZfK9XKg7Bx6ACA5MD92HV9FIoneZ6l0NdhR8hJQTgRkaCiG1N7e
CTOwKA1xSCTVy9UJBzhOsRhpVuYhw6lhqexj75a8oQAGxKdSfP3b/yAvTGIDpXar
IL+yqi6KVVmk9buqFmzHaDY6+f6u8bFZTHKLblWkwzaVhAoQDMz8GjjsttBIvl35
GdhVM1GTo24=
=sZSs
-----END PGP SIGNATURE-----

--=-/dhhNfUFDGnIA7J/FHP9--

