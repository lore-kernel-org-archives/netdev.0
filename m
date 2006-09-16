From: Michael Wu <flamingice@sourmilk.net>
Subject: Re: [d80211] connecting to B-mode AP
Date: Fri, 15 Sep 2006 20:04:54 -0400
Message-ID: <200609152004.59652.flamingice@sourmilk.net>
References: <C86180A8C204554D8A3323D8F6B0A29F01785374@dhost002-46.dex002.intermedia.net> <450B3C51.208@linux.intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart20688677.2xxQ41MR7H";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Simon Barber <simon@devicescape.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from server8.tchmachines.com ([216.180.241.250]:16527 "EHLO
	server8.tchmachines.com") by vger.kernel.org with ESMTP
	id S932243AbWIPAGH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Sep 2006 20:06:07 -0400
To: mabbas <mabbas@linux.intel.com>
In-Reply-To: <450B3C51.208@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart20688677.2xxQ41MR7H
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Friday 15 September 2006 19:50, mabbas wrote:
> I see your point here, although some one will file some bugs against the
> driver about showing G while associating with B-mode AP. By the way how
> can you figure if the AP is B/G other than the rates?
>
IIRC, only 802.11g APs will send the extended rate information element, tho=
ugh=20
I don't know if forcing 802.11b on the AP will cause it to stop sending tha=
t.=20
(but it might still be okay if it doesn't - it's still a 802.11g AP, with t=
he=20
faster speeds turned off..)

=2DMichael Wu

--nextPart20688677.2xxQ41MR7H
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBFCz+rT3Oqt9AH4aERAlYeAKCQpvpe643yRn8l37SDYcNCi05y/ACfau4x
/qZgj4eIgjBPJbC50zLNUSo=
=xmky
-----END PGP SIGNATURE-----

--nextPart20688677.2xxQ41MR7H--
