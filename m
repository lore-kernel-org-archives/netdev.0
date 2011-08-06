From: Ben Hutchings <bhutchings@solarflare.com>
Subject: ethtool 3.0 released
Date: Sat, 06 Aug 2011 13:00:39 +0100
Message-ID: <1312632039.2591.976.camel@deadeye>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512"; protocol="application/pgp-signature"; boundary="=-qVoNTEWMcrRhpMdSo3cP"
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:29359 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752544Ab1HFMAl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Aug 2011 08:00:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



--=-qVoNTEWMcrRhpMdSo3cP
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

[OK, Evolution seems to be confused about which account I'm using.]

ethtool version 3.0 has been released.

Home page: https://ftp.kernel.org/pub/software/network/ethtool/
Download link:
https://ftp.kernel.org/pub/software/network/ethtool/ethtool-3.0.tar.gz

Release notes:

        * Feature: Report supported pause frame modes
        * Feature: Support firmware dump (-w and -W options)
        * Feature: Report advertised and supported 20G link modes
        * Feature: Add an 'l4data' option for ip4 filters (-U option)
        * Fix: Correct swapped h_source and h_dest fields for ether filters
          (-U option)
        * Fix: Set ip_ver field correctly for ip4 filters (-U option)
        * Fix: Correct parameter validation for -e and -E options; in
          particular, treat the 'magic' value as unsigned

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.


--=-qVoNTEWMcrRhpMdSo3cP
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEVAwUATj0s4GkILBsOca60AQoOpwf8C2+x01B5K540X11LWoF5q+cgUm5CRvxV
l7kCJM+mVA/afsxiZDwD0RIXNKMH3S42evZ8ieuPQ5tliHyv16oGkpEFmLc4vYkp
hcaz20PHPtZRxiFNR9hemsrtORG5Kq1CjV+NRLOpxyy0ZvCUIsu8Q6h4PCOmjOYH
1RH+3YNYe7XqwAi7b48NjWgRp2zjJXqvvr1O/XIMytmLHPtu22d5GGHV9y2VrX8d
oUaGFeWm0JD8mVUUNdwwBZZ/f350QxvsLCfzGCNQZuXsU9g1r1T02JDf2qjstdl0
IguvSBbFZfP39I7TxVxd80C3PUfJT8L4czKT9Do8Awl+2J9AN79wFg==
=w8lr
-----END PGP SIGNATURE-----

--=-qVoNTEWMcrRhpMdSo3cP--

