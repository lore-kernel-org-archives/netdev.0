From: Vladimir Kondratiev <vkondra@mail.ru>
Subject: Re: [RFC] acx100 inclusion in mainline; generic 802.11 stack
Date: Tue, 28 Sep 2004 22:29:48 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200409282229.53349.vkondra@mail.ru>
References: <200408312111.02438.vda@port.imtp.ilyichevsk.odessa.ua> <413F70F0.6020709@atheros.com> <20040928122028.GK30131@ruslug.rutgers.edu>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart15673523.bRENPlNFVd";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: greg chesson <greg@atheros.com>, netdev@oss.sgi.com,
        "David S. Miller" <davem@davemloft.net>,
        acx100-devel@lists.sourceforge.net, hadi@cyberus.ca, jgarzik@pobox.com,
        jkmaline@cc.hut.fi, prism54-devel@prism54.org, sam@errno.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Luis R. Rodriguez" <mcgrof@studorgs.rutgers.edu>
In-Reply-To: <20040928122028.GK30131@ruslug.rutgers.edu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--nextPart15673523.bRENPlNFVd
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Tuesday 28 September 2004 14:20, Luis R. Rodriguez wrote:
LR> RFC: what are the chances we can implement our own generic "softmac" th=
at
 may LR> be usable by the different chipsets out there?

Coming days, I will submit "framework" consisting of stack based on Dave's=
=20
code and debug driver which will be able to imitate Rx. I have working basi=
c=20
Tx/Rx. Then, I'd like to concentrate on interfaces stack-driver and=20
stack-upper layers. It would be great if someone will do MAC algorithms. I'=
ll=20
appreciate this for sure.

Vladimir.

P.S. My ... provider complains about "too many recipients". I removed one o=
r=20
2. Sorry.

--nextPart15673523.bRENPlNFVd
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.6 (GNU/Linux)

iD8DBQBBWcnBqxdj7mhC6o0RAsZVAJ0ZEXrrodpotOLgYIWN8x8+w7oeLACfXfvE
zVu9wkndLuqAVfgxYV856eQ=
=gsqL
-----END PGP SIGNATURE-----

--nextPart15673523.bRENPlNFVd--
