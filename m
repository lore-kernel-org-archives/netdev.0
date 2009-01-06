From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [PATCH] net/ehea: bitops work on unsigned longs
Date: Tue, 6 Jan 2009 11:11:48 +1100
Message-ID: <20090106111148.90da9b78.sfr@canb.auug.org.au>
References: <20081231141853.c6d123c4.sfr@canb.auug.org.au>
	<20081230.215156.151347026.davem@davemloft.net>
	<20090106105951.62b0429d.sfr@canb.auug.org.au>
	<20090105.160535.24967514.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Tue__6_Jan_2009_11_11_48_+1100_IRgU9yNttcNMywX1"
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org, raisch@de.ibm.com,
	themann@de.ibm.com, tklein@de.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from chilli.pcug.org.au ([203.10.76.44]:34935 "EHLO smtps.tip.net.au"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750863AbZAFAMB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Jan 2009 19:12:01 -0500
In-Reply-To: <20090105.160535.24967514.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Signature=_Tue__6_Jan_2009_11_11_48_+1100_IRgU9yNttcNMywX1
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave,

On Mon, 05 Jan 2009 16:05:35 -0800 (PST) David Miller <davem@davemloft.net>=
 wrote:
>
> Aha, yes the commit message fooled me :-)  New patch is fine and
> I'll toss this into net-2.6

I will try to do better in the future, thanks.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Tue__6_Jan_2009_11_11_48_+1100_IRgU9yNttcNMywX1
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkliocQACgkQjjKRsyhoI8w7HACfYAgOyx9NXyXR5JgRkLniWWNQ
dggAn14ZZDw6CRCpQVf9wRwQXjzYolqE
=B87q
-----END PGP SIGNATURE-----

--Signature=_Tue__6_Jan_2009_11_11_48_+1100_IRgU9yNttcNMywX1--
