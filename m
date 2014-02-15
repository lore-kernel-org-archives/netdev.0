From: Antonio Quartulli <antonio@meshcoding.com>
Subject: Re: [PATCH] Drivers: net: wireless: mac80211_hwim fixed coding style
 issues
Date: Sat, 15 Feb 2014 20:53:17 +0100
Message-ID: <52FFC5AD.4080003@meshcoding.com>
References: <1392465312-3780-1-git-send-email-justinvanwijngaarden@gmail.com>	 (sfid-20140215_125633_755512_88424C91) <1392488030.4298.5.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="u5sScl5giA9ifmmOjHseclV9SsTcuG5XF"
Cc: linville@tuxdriver.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>,
	Justin van Wijngaarden <justinvanwijngaarden@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:20011 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753432AbaBOTy4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Feb 2014 14:54:56 -0500
In-Reply-To: <1392488030.4298.5.camel@jlt4.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--u5sScl5giA9ifmmOjHseclV9SsTcuG5XF
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 15/02/14 19:13, Johannes Berg wrote:
> On Sat, 2014-02-15 at 12:55 +0100, Justin van Wijngaarden wrote:
>=20
>> @@ -1,19 +1,17 @@
>> -/*
>> - * mac80211_hwsim - software simulator of 802.11 radio(s) for mac8021=
1
>> +/* mac80211_hwsim - software simulator of 802.11 radio(s) for mac8021=
1
>=20
> I don't see any point in this - lots of code exists both ways, that's
> really just fluff. The difference isn't even interesting enough to be
> worth fixing up.

This is how David S. Miller wants multiline comments to start in files
within the networking subsystem......but I know you don't like it ;)
(I just wanted to justify Justin).


Cheers,

--=20
Antonio Quartulli


--u5sScl5giA9ifmmOjHseclV9SsTcuG5XF
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJS/8WzAAoJEEKTMo6mOh1VCPUP/11uvQjLpB59ZHtdbtsZKbJC
3zT0YeV+gKQfrxEYt2SbHxRYjxlcn/J66z30ihBq6lcxRe82XDkAH8+fIcsn2Lw5
saEFbsoRMeTJZoHWn6D69rUYyYNEzElE2mv9j2Gql9w8AB7jK78QkSoLWUIqsq/I
6fRwMBBq0aaaBj+lqz1yVDGr8dfiyxw4BzovY1fpzMymnIJigdJY5ZloezoR74Ap
wrHOs8y6rLQcepR6wVTRhrMRjL/88Xph5Z4IbQeR1jmDtUnAoEd/cZ/jhrSNQo3d
IXi7lOBqkGt9Vm/7+RNz0C/TpCUnMYE7G5nASynmxBlLadWFnsxOFBSf3iN3FX4R
8BC+Z5ZZ5P4u8h9s+MS31G9e28Bbp4FdDPEaO46eplHaIVBNZDQ4++0e4msPgje+
o2ECnPJ05BUtlWoCmsWkyNlr14pRDSz3+WAQFtihxVKC1CrMSE0jMCgzya1bV/EF
rQTJJpM1G0RkHX0mawKQdCgxlqAHk08O7uy2VtBLoZUmPs8QHjmMko+8Loluhagt
Gi/JKJU8b4qlqmIlLzd1aDyrQF7v7w1wuaqI3cynSRg66ZvmFpOodAxJFhbm7YGp
pa2ek2frvz5pytQkBZ1E/Xrgt5EnDjbLwqi5dq/S45M0zir9t+zbxJDYmcsbL5Kh
TfoPwL7XJd4eYPIQZlIB
=Njal
-----END PGP SIGNATURE-----

--u5sScl5giA9ifmmOjHseclV9SsTcuG5XF--
