From: Michael Wu <flamingice@sourmilk.net>
Subject: Re: [PATCH 0/6] rework d80211 cookie pointer
Date: Fri, 3 Nov 2006 14:04:16 -0500
Message-ID: <200611031404.32926.flamingice@sourmilk.net>
References: <20061102223854.692274000@sipsolutions.net>>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1318705.ux1KjfUkEo";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>, netdev@vger.kernel.org,
	Ivo van Doorn <ivdoorn@gmail.com>,
	John Linville <linville@tuxdriver.com>,
	Michael Buesch <mb@bu3sch.de>, Hong Liu <hong.liu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.rutgers.edu ([128.6.72.243]:42277 "EHLO
	annwn14.rutgers.edu") by vger.kernel.org with ESMTP
	id S1753456AbWKCTEr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Nov 2006 14:04:47 -0500
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <20061102223854.692274000@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1318705.ux1KjfUkEo
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Thursday 02 November 2006 17:38, Johannes Berg wrote:
> I'm sorry I didn't manage to update these drivers. As for out-of-tree
> drivers, I obviously haven't updated them either. It *shouldn't*
> be too hard as the net_dev shouldn't be used in many places.

So uh, what am I going to prefix all my printk messages with now that I can=
't=20
access dev->name? It seems like the other d80211 drivers have a habit of=20
prefixing their messages with the driver name (wrong thing to do, IMHO),=20
which is different from pretty much all other network drivers.

=2DMichael Wu

--nextPart1318705.ux1KjfUkEo
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBFS5LAT3Oqt9AH4aERAhRVAKC6sUdclhvBqvI4sEtKtp2IpVYStACgg498
Y87RRRXkEnSbx1fM4dn4uRU=
=xUaf
-----END PGP SIGNATURE-----

--nextPart1318705.ux1KjfUkEo--
