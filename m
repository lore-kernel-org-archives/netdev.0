From: Stanislav Karchebny <berk@upnet.ru>
Subject: forcedeth 0.20 eth0: received interrupt report
Date: Sun, 11 Jan 2004 21:33:54 +0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200401112134.05375.berk@upnet.ru>
Mime-Version: 1.0
Content-Type: multipart/signed;
  protocol="application/pgp-signature";
  micalg=pgp-sha1;
  boundary="Boundary-02=_9rXAACFcySNAWxL";
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Carl-Daniel Hailfinger <c-d.hailfinger.kernel.2003@gmx.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--Boundary-02=_9rXAACFcySNAWxL
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

"eth0: received irq with unknown events 0x21. Please report"

This happens when i enable software CPU cooling on nForce2 chipset using=20
=46Vcool - this causes all nforce-net connections to fail miserably and the=
se=20
events are generated in dmesg log.

The very moment i disable softcooling using fvcool -d the network resumes=20
normal operations.

Linux Kernel 2.6.0 final
forcedeth 0.20
ASUS A7N8X Deluxe mobo

=46eel free to contact me if you need any additional information/debug=20
runs/testing help.

=2D-=20
keep in touch. berkus.

--Boundary-02=_9rXAACFcySNAWxL
Content-Type: application/pgp-signature
Content-Description: signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iD8DBQBAAXr98v4MNv5cuDkRAm+pAJ98Sw3R3DXyJYku07RSLx6tZZGqeACeOGRM
zVfq+J1t1yyzzxMBhCQ+bEc=
=Jrxj
-----END PGP SIGNATURE-----

--Boundary-02=_9rXAACFcySNAWxL--
