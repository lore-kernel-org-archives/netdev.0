From: Ulrich Drepper <drepper@redhat.com>
Subject: Re: [RFC 1/4] kevent: core files.
Date: Fri, 28 Jul 2006 20:38:02 -0700
Message-ID: <44CAD81A.9060401@redhat.com>
References: <20060709132446.GB29435@2ka.mipt.ru> <20060724.231708.01289489.davem@davemloft.net> <44C91192.4090303@oracle.com> <20060727200655.GA4586@2ka.mipt.ru> <44C930D5.9020704@oracle.com> <20060728052312.GB11210@2ka.mipt.ru> <44CA586C.4010205@oracle.com> <20060728184445.GA10797@2ka.mipt.ru> <44CA613F.9080806@oracle.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig1B2C08651A93A5532AC0B66A"
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:54432 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1752006AbWG2Dgg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2006 23:36:36 -0400
To: Zach Brown <zach.brown@oracle.com>
In-Reply-To: <44CA613F.9080806@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig1B2C08651A93A5532AC0B66A
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Zach Brown wrote:
> Ulrich, would you be satisfied if we didn't
> have the userspace mapped ring on the first pass and only had a
> collection syscall?

I'm not the one to make a call but why rush things?  Let's do it right
from the start.  Later changes can only lead to problems with users of
the earlier interface.

--=20
=E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro St =
=E2=9E=A7 Mountain View, CA =E2=9D=96


--------------enig1B2C08651A93A5532AC0B66A
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.4 (GNU/Linux)
Comment: Using GnuPG with Fedora - http://enigmail.mozdev.org

iD8DBQFEytga2ijCOnn/RHQRAvDpAJwJWFGyrC5rJZMjNF/h2l3NhV739QCfdt0E
6TYaA/HYfEsA7aV0f/bdBTw=
=frO5
-----END PGP SIGNATURE-----

--------------enig1B2C08651A93A5532AC0B66A--
