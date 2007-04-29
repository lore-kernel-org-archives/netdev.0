From: Ulrich Drepper <drepper@redhat.com>
Subject: Re: [RFC] [GIT PATCH net-2.6.23] IPV6: Configurable IPv6 address
 selection policy table (RFC3484)
Date: Sun, 29 Apr 2007 12:43:21 -0700
Message-ID: <4634F559.10603@redhat.com>
References: <20070419.162856.20840698.yoshfuji@linux-ipv6.org>	<20070428.231707.39159334.davem@davemloft.net>	<46343D9A.8010201@redhat.com> <20070429.120218.115910157.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig9C4AF60481094548C6F7FDB7"
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:48169 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1031283AbXD2Tnm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 29 Apr 2007 15:43:42 -0400
In-Reply-To: <20070429.120218.115910157.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig9C4AF60481094548C6F7FDB7
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

David Miller wrote:
> Something more scalable has to be used.

This is where the shared-memory based event notification comes in.  It
was always also meant to be used for things like this.

--=20
=E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro St =
=E2=9E=A7 Mountain View, CA =E2=9D=96


--------------enig9C4AF60481094548C6F7FDB7
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)
Comment: Using GnuPG with Fedora - http://enigmail.mozdev.org

iD8DBQFGNPVZ2ijCOnn/RHQRAq1nAJ9YmI6MRoGLIeCZ/o+41YAZvoVO+gCgluBh
ET357kAszqYGJI4pZbiW8fk=
=56GG
-----END PGP SIGNATURE-----

--------------enig9C4AF60481094548C6F7FDB7--
