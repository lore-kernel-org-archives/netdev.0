From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC PATCH] softmac: (v2) send WEXT assoc/disassoc events to
	userspace
Date: Sat, 15 Apr 2006 21:25:05 +0200
Message-ID: <1145129105.6560.2.camel@localhost>
References: <1141928917.26954.7.camel@localhost.localdomain>
	 <1141935893.28038.2.camel@localhost.localdomain>
	 <441091B8.4010103@lwfinger.net>
	 <1141936896.28038.6.camel@localhost.localdomain>
	 <1144886208.4187.26.camel@localhost>
	 <20060413001909.GB23116@falcon.fugal.net>
	 <1144887916.4187.28.camel@localhost>
	 <20060413002816.GC23116@falcon.fugal.net>
	 <1144888334.4187.32.camel@localhost>
	 <20060414010545.GA10636@falcon.fugal.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-3eC2TO/mjwFo8tsma6T7"
Cc: Larry Finger <Larry.Finger@lwfinger.net>, netdev@vger.kernel.org,
	softmac-dev@sipsolutions.net, David Woodhouse <dwmw2@redhat.com>,
	Dan Williams <dcbw@redhat.com>, bcm43xx-dev@lists.berlios.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([213.151.39.204]:16007 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1751268AbWDOTZL
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Apr 2006 15:25:11 -0400
To: Hans Fugal <hans@fugal.net>
In-Reply-To: <20060414010545.GA10636@falcon.fugal.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-3eC2TO/mjwFo8tsma6T7
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2006-04-13 at 19:05 -0600, Hans Fugal wrote:
> With the patch, wpa_supplicant is able to work properly for WEP and
> plaintext as tested with my bcm4306 (iBook), and the latest git.

Thanks, great. I have network-manager up and running too now (finally!)

> However, and this may not be related, I still must issue an=20
>=20
>     ip link set up eth1
>=20
> after loading the bcm43xx module but before starting wpa_supplicant or
> it will not work.=20

Right, that is expected behaviour right now until we come up with how to
handle this properly.

johannes

--=-3eC2TO/mjwFo8tsma6T7
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIVAwUAREFIkKVg1VMiehFYAQKw+g//Q/Yl1o/AZXyh2pa33J1vQYD9AeDsunaj
JzEq25LDgnT9SF0VViC1coRGAfg4xAOxrMbylKZr/nmuMhWRiF3wkUgD8TwLvQfN
fuIPci3In/25XKEKqi+LxvxotKPLRjvy5nyIr3Nr7TyN1knAJOz7mqnaEQvJXjK/
HpNz8TY0aCmcyRP/wtu5rfOtO90ylrpBPhYstBIR76QnmTR5P0PuY5TABI6C34rN
15iwhzJF2ajB4Prm/VIapWZ3rdi2NOAe+z4ZDUDLDAoUdnM5T/MDd5mLcMPnDG4y
99cIxolCMnXMoIZLt7uqRKfHJ6z54IFHjXmm7Tj3EG/YKlLYkQOJ8okrnm/nPA3Y
qmUTFW/pnBwhoxCZYWEaUIQOd3qx7VVoz4VR3nsOp9J7x4dl7hiaExeL5eEhrZ8U
tr7dbaKpYvLDtbe7IuD/T792m1elkHzT/EQ2J9bg/bpOvHAKNdF8Dn9p/iOgmKUg
HBruHcDSBQh81BVVL3mify4yX04L/k/Z2J+qrkYhBKsmPWkPgRWwsEuZzd7q/sqh
z1QQ64gSyHUv3h28LbEDRGLoLEZY0Tk9CIfAv+8Enpz0KPvfq0MG12tf3X0IoYe7
0zSNNdYcOSdq78LHWUGxN2uUOEQ2UFJhur5MJFXAUcTq/TIVvRy/1JjgTL0gLLky
977E4VqkBCA=
=Ph4Y
-----END PGP SIGNATURE-----

--=-3eC2TO/mjwFo8tsma6T7--

