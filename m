From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: 2.6.24-rc5-mm1 -- INFO: possible circular locking dependency
	detected -- pm-suspend/5800 is trying to acquire lock
Date: Tue, 18 Dec 2007 15:08:06 +0100
Message-ID: <1197986886.4885.156.camel@johannes.berg>
References: <a44ae5cd0712180603v2a37023dj714a8500c14c08de@mail.gmail.com>
	 (sfid-20071218_140331_639413_FA8FEBF7)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-BNmijsOA0s70fjnylvjg"
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	ipw3945-devel@lists.sourceforge.net,
	Len Brown <len.brown@intel.com>, Pavel Machek <pavel@suse.cz>,
	"Rafael J. Wysocki" <rjw@sisk.pl>
To: Miles Lane <miles.lane@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:38895 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755551AbXLROIn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Dec 2007 09:08:43 -0500
In-Reply-To: <a44ae5cd0712180603v2a37023dj714a8500c14c08de@mail.gmail.com> (sfid-20071218_140331_639413_FA8FEBF7)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-BNmijsOA0s70fjnylvjg
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


On Tue, 2007-12-18 at 09:03 -0500, Miles Lane wrote:
> I have only seen this happen once, and cannot reproduce it.  I'll keep
> trying, though.
>=20
> Dec 16 22:10:48 syntropy kernel: [  231.718023]
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D

Do you have a version that isn't line-wrapped before I try to unwrap it?

Thanks,
johannes

--=-BNmijsOA0s70fjnylvjg
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUAR2fURaVg1VMiehFYAQLaKQ/+OC9McTwIpKYiqW7a78BOW1/ncYXEir9v
RACKn4H8oHmy0eRlweLNEc4u7Ax67ymFhMlbGme+dQvpDtADVDyDxxEx6hu8yy9f
GNsntj7jV8CEl0VALxjcqm4mdQ6BfyBJuu/90aE346R2SL9JUGTgnfEmJ2sTCIIt
qi6KQj2MwJYHENGFy/wABc8Wo2Zr1CQWIqBJLzIBUITcv7irfNrtnx0bGor0hLg3
H+NlIDywEkgeOzCQkvIMCIC33q1Tk9RL4bEJjLURseIL4MJYdEpWgoo50OPHCcXg
hsAIhZHETBjTZHOVlMHkolI4uAeMbrl87aEk6K6r0umCcbqWSgqx0ZkbXrIWjTVP
6je4ZIRQlX/jqHCEvkBQZ9Sao2FxnbtzlyhhdtRuaRGaxEkD3pPeijOUNzLlhMRw
GzwpiYEihH7y3xcDwIlfhAYbbSUXhIVYWPfF7AgSsnua+NCEhGZOgXGRNYHy+00M
GjhHExe585FTi9Nl0Ld6mPsnYZcka2wINw5l4bN4cn8Fa7If0Hsb+eMDxDwv8Bp0
kdxFNOiC3QLMsu3g6EQQLca2oFIs6gOu9oHTtC0EC5706uRq5yo0ICLcUQPB0ll4
HxGQvCTL7IOg/8KsqMkstz4ulwn8QTqG0L6aLOTVTdlgJ1lN1YD6GbTs07gsv46v
0U6ObGrXAw8=
=nWKb
-----END PGP SIGNATURE-----

--=-BNmijsOA0s70fjnylvjg--

