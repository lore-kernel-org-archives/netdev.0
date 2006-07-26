From: Michael Wu <flamingice@sourmilk.net>
Subject: Re: [PATCH dscape] d80211: Switch d80211.h to IEEE80211_ style names
Date: Wed, 26 Jul 2006 09:43:55 -0700
Message-ID: <200607260944.01692.flamingice@sourmilk.net>
References: <200607242302.58670.flamingice@sourmilk.net> <20060726183200.79fb431e@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1313379.5FbmeIHicL";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from server8.tchmachines.com ([216.180.241.250]:9430 "EHLO
	server8.tchmachines.com") by vger.kernel.org with ESMTP
	id S932170AbWGZQoB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Jul 2006 12:44:01 -0400
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20060726183200.79fb431e@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1313379.5FbmeIHicL
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Wednesday 26 July 2006 09:32, Jiri Benc wrote:
> One more thing (hopefully the last one), could you try to keep lines
> under 80 characters? I understand that with such long identifiers it is
> not always possible (it dramatically reduces readability of the code if
> you try to force the limit in every case) but there are some places
> where it is feasible.
>
Ah, yeah, that was a problem..

> Also, when changing a line that is indented with spaces instead of tab
> characters, it's nice to convert that spaces to tabs. That's not a
> requirement, though; I will modify the patch if you won't do it.
>
I still want to convert d80211_mgmt.h. Once that's done, I'll look through =
for=20
those tabs/spaces & long lines formatting issues. I won't mind if you start=
=20
fixing some of those issues now, however. :)

=2DMichael Wu

--nextPart1313379.5FbmeIHicL
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBEx5vRT3Oqt9AH4aERAm+4AKDI9D0t9BpkOdLCwW1rkvycklgf0gCeK0AG
J58i8RGwKcx0fWpBrktVwW0=
=DCl1
-----END PGP SIGNATURE-----

--nextPart1313379.5FbmeIHicL--
