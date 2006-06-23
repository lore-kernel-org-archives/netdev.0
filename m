From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: Streamline testing of 802.11 drivers
Date: Fri, 23 Jun 2006 23:38:26 +0200
Message-ID: <200606232338.26801.IvDoorn@gmail.com>
References: <43e72e890606231333kd0fc534x5d08dad955d13bf5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart6262131.lEPzy2ipX4";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, zd1211-devs@lists.sourceforge.net,
	"Ivan Seskar" <Seskar@winlab.rutgers.edu>,
	"Kishore Ramachandran" <kishore@winlab.rutgers.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.191]:65443 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1752089AbWFWVeO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Jun 2006 17:34:14 -0400
Received: by nf-out-0910.google.com with SMTP id m19so271819nfc
        for <netdev@vger.kernel.org>; Fri, 23 Jun 2006 14:34:12 -0700 (PDT)
To: "Luis R. Rodriguez" <mcgrof@gmail.com>
In-Reply-To: <43e72e890606231333kd0fc534x5d08dad955d13bf5@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart6262131.lEPzy2ipX4
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi,

> I've mentioned this to a few but here it is out to everyone. So as you
> know we have a lot of work ahead of us for linux wireless development.
> To help speed this up, we at Winlab, would like to start hosting a
> testbed for linux wireless development, open to the public. Short term
> goals would be to start off a couple of nodes for each driver
> currently under development like bcm43xx, zd1211, rt2x00, ipw3945,
> ipw2200 and the like, and a provide a set streamlined tests we can use
> to really put to test the drivers and stacks.

This would be really interesting. :)

> This wouldn't be easy if we didn't have infrastructure but we already
> do. Our grid consists of 400 nodes with 2 wireless cards each and 3
> ethernet ports (one for control) --
> http://orbit-lab.org/wiki/Tutorial/Testbed. 90% of our nodes use the
> atheros 5213 chipset and the rest ipw2200s. We'd like to expand this
> with the more wireless cards currently being worked on for linux.
>=20
> Right now we have zome zd1211s so we'll start with that (I'll start
> working on a port to d80211) but will try to accomodate other nodes as
> we get more wireless cards. We will need some help too though, to
> streamline the testing. If you have ideas or would like to contribute
> please let me know. We can purchase wireless cards but if you already
> have reliable confirmed wireless cards which can be used for putting
> into the testbed let me know.

I'll discuss this in the rt2x00 team, and see if we can donate some
hardware.

Ivo

--nextPart6262131.lEPzy2ipX4
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBEnF9SaqndE37Em0gRAo2aAJ9MUZ5AaWXxr1neAV9tLWErKU5eqwCg5Aee
/2SeoskPofkQ7Z6Hm3P8t8s=
=8kXN
-----END PGP SIGNATURE-----

--nextPart6262131.lEPzy2ipX4--
