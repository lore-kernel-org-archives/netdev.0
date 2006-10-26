From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC] [PATCH 0/3] Add Regulatory Domain support to d80211
Date: Thu, 26 Oct 2006 23:48:34 +0200
Message-ID: <1161899314.8884.32.camel@johannes.berg>
References: <20061024140212.GB17543@devicescape.com>
	 <C86180A8C204554D8A3323D8F6B0A29F018523A5@dhost002-46.dex002.intermedia.net>
	 <43e72e890610241503r692975dfx65b2eab987ffbb3d@mail.gmail.com>
	 <200610241853.03135.flamingice@sourmilk.net>
	 <43e72e890610251043y22fb9ce6ne5e036dd58f36505@mail.gmail.com>
	 <1161813628.8884.14.camel@johannes.berg>
	 <1161873333.2927.9.camel@localhost.localdomain>
	 <43e72e890610260804q28505f71v6053f8dbbd457ac7@mail.gmail.com>
	 <1161876783.2927.37.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-m9t6qCks4aZTPH2FBfJq"
Cc: "Luis R. Rodriguez" <mcgrof@gmail.com>,
	Michael Wu <flamingice@sourmilk.net>,
	Simon Barber <simon@devicescape.com>,
	David Kimdon <david.kimdon@devicescape.com>,
	netdev@vger.kernel.org, Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	Jean Tourrilhes <jt@hpl.hp.com>, Hong Liu <hong.liu@intel.com>,
	Jouni Malinen <jkmaline@cc.hut.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:51338 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1945949AbWJZVtq
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Oct 2006 17:49:46 -0400
To: Dan Williams <dcbw@redhat.com>
In-Reply-To: <1161876783.2927.37.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-m9t6qCks4aZTPH2FBfJq
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2006-10-26 at 11:33 -0400, Dan Williams wrote:

> The one blocker I can think of here is startup scripts on various
> distributions.  Most of those are shell, and they usually rely on
> iwconfig quite heavily.  Getting those converted to wpa_supplicant
> wouldn't be a trivial amount of work, but it wouldn't be a ton either.

But as I've said forever... I intend to leave WE working when we move to
cfg80211. We can't rip out the old userspace API just like that.

johannes

--=-m9t6qCks4aZTPH2FBfJq
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUARUEtMaVg1VMiehFYAQKtwBAApUt8iZfqLqk341caGLeCalp8yowgKsIv
7iyRWEPhxu7ouG7kgpYjDOJWuwevn0al+T2BfQH2fO9lceJJfEUcOzxC9Z6OExmR
iRsMiTta4uGhkPqcGc3hw/3DwYVw9FWZJJDPndgWmOPOl4yIQKd24ASGvfkNZ9Oq
25Xh+cAVoYfvfDk1c38dsb6OO/mypPD2rCEPzsN7Gl6KgEyAjORTAg3FT1zeY1c3
WoFTbvMsC0GwzzCuN+sGvt8FuVOn1JELYXjymdiWhKzrdy3YQ8ZN6thrOfyneyg1
2ecM8wkULaH8D8rpt/4JyQlj2IQb/8UFgQoQvWRcYib3EFq0TSBcAozk07mqHRGF
fOc54bet0jSQAbp0hwE/jtJ5O5dHryJAXkwyjY4gWPozu+ga4ORfTVCWGUCPVqok
C4WANLvhcnZddhva3xVAw67Trvzk1NQFDWZspre/DEDhkwOEE0OQg5V3jgXcatQB
rWxzCrlkGFsqPgnCCw12ZDIjiGHYz5Mu+/HWh2yz6aSKLaCTpbOeKOHyJZaYiNsm
acK2RPxkQriyco6RN3pjssjqtaY93cvgY3RPAiOvIkT1/FAt1uM+cVDrSyqNlNVq
ksWxxTX8wMykOXY28o+fuzM0qEoWQIj4XblVkomWSHiQG4cIBGjolFhUKltN55G8
+XQBvkqiyWk=
=2YJy
-----END PGP SIGNATURE-----

--=-m9t6qCks4aZTPH2FBfJq--

