From: ext martin f krafft <madduck@madduck.net>
Subject: Re: pseudo interface with different hwaddr
Date: Tue, 10 Feb 2009 13:51:10 +0100
Message-ID: <20090210125110.GA16955@piper.oerlikon.madduck.net>
References: <20090210112508.GA16497@piper.oerlikon.madduck.net> <200902101343.49743.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="bp/iNruPH9dso1Pn"
To: netdev discussion list <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from clegg.madduck.net ([193.242.105.96]:55769 "EHLO
	clegg.madduck.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751920AbZBJMvW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2009 07:51:22 -0500
Received: from wall.oerlikon.madduck.net (wall.oerlikon.madduck.net [IPv6:2001:41e0:ff12::1])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(Client CN "wall.oerlikon.madduck.net", Issuer "CAcert Class 3 Root" (verified OK))
	by clegg.madduck.net (postfix) with ESMTPS id CF6951D409B
	for <netdev@vger.kernel.org>; Tue, 10 Feb 2009 13:51:11 +0100 (CET)
Received: from piper.oerlikon.madduck.net (piper.oerlikon.madduck.net [IPv6:2001:41e0:ff12:0:211:2fff:fe6b:c869])
	by wall.oerlikon.madduck.net (Postfix) with ESMTPS id B18C39F13D
	for <netdev@vger.kernel.org>; Tue, 10 Feb 2009 13:51:10 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <200902101343.49743.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--bp/iNruPH9dso1Pn
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

also sprach R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com> [2009.02.=
10.1243 +0100]:
> Wouldn't macvlan solve this?

Thanks for the pointer. I will have to compile a kernel to test this
though, Debian has it disabled (#504611)... :(

I will report back.

Thanks!

--=20
martin | http://madduck.net/ | http://two.sentenc.es/
=20
drink canada dry! you might not succeed, but it *is* fun trying.
=20
spamtraps: madduck.bogus@madduck.net

--bp/iNruPH9dso1Pn
Content-Type: application/pgp-signature; name="digital_signature_gpg.asc"
Content-Description: Digital signature (see http://martin-krafft.net/gpg/)
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkmReD0ACgkQIgvIgzMMSnXG4gCgzyTcMOv7vbnTIzEJacImOe1J
ywAAoOe1J/2/TAH111dwSagfWRWAclFk
=8NW6
-----END PGP SIGNATURE-----

--bp/iNruPH9dso1Pn--
