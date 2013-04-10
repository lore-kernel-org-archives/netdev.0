From: Martin Pitt <martin.pitt@ubuntu.com>
Subject: Re: [mac80211-next:wip 107/122]
 drivers/net/wireless/mac80211_hwsim.c:2198:17: warning: ignoring return
 value of 'driver_register', declared with attribute warn_unused_result
Date: Wed, 10 Apr 2013 18:38:59 +0200
Message-ID: <20130410163859.GA2884@piware.de>
References: <51658900.3wb5UKoIEe45MUXS%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="1yeeQ81UyVL57Vl7"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>
To: Johannes Berg <johannes.berg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.piware.de ([213.9.93.70]:48584 "EHLO www.piware.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932468Ab3DJQjD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Apr 2013 12:39:03 -0400
Content-Disposition: inline
In-Reply-To: <51658900.3wb5UKoIEe45MUXS%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--1yeeQ81UyVL57Vl7
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hello Johannes,

kbuild test robot [2013-04-10 23:45 +0800]:
>    drivers/net/wireless/mac80211_hwsim.c: In function 'init_mac80211_hwsi=
m':
> >> drivers/net/wireless/mac80211_hwsim.c:2198:17: warning: ignoring retur=
n value of 'driver_register', declared with attribute warn_unused_result [-=
Wunused-result]

Argh, I wish I could see these warnings with the standard make
command, sorry about that. Sending a patch for this.

Martin
--=20
Martin Pitt                        | http://www.piware.de
Ubuntu Developer (www.ubuntu.com)  | Debian Developer  (www.debian.org)

--1yeeQ81UyVL57Vl7
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJRZZWfAAoJEPmIJawmtHufyGEP/isrUd0oGO1Y2HVr95H4FiZY
H8aNxdj1wn4f31IjPckzIrNrWc4eHc+lfe+MTsZ6RW3U/2PMuFy7iiHalp69xnvt
LzVC1sHyu5Nisl/8QG5dZ4WmmYZ2f6qtrdDmLrej7HuMVD2ynkEM76YaHrIPDQDf
X2BeofoHnT9Y3Kf9cejXST7e4SawSpceAHCElP8fI0zPnN38zS/IVAu9MkL8NU1n
IngLVlysTm/AiGjohkMIB7OJmvlFrEbZ5j/ku9HwHG1TsI0iFudPiTP1gzgdiehO
ZsMQGdkseqrzOk18N9MsVZ7pk/qzMSc4upAFFP9Tb3jN3ITNkOzIQCpEM8SmvwEP
kJCHhkbwj/yTBmBShu6+7itUqajnq+QBeJleGxc4j1+13Hgc67CLqIhivGmKvGfX
Pnz10W0kwDV1vTe6QaAm+IuSal+uyMnwySMkf0yTyWYQz41bENXXJZT6XozcUPJn
c6WgY1a6LGiWj7NtNGawfqAxmKshz3IgxP80DhRv/Vc/MYgJLXZdQ6wPzSAIk+P9
MqkPYrx7008lOATAT5XEZZRr4ZkKG3maB4i2BqOkkV/mzWIJhzaqkUcpcp8iSCNu
55BobZRnzOzKMGOVAVyPSUtUpSlrbnHUXZi3MNex7jqFVstaIr5iSm8V7vsC4Z7Y
Sj6wHcoYzNyTW4ubjMTF
=15i9
-----END PGP SIGNATURE-----

--1yeeQ81UyVL57Vl7--
