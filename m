From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Mon, 25 Jun 2012 13:33:18 +1000
Message-ID: <20120625133318.a57079c86bad4360828efac0@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Mon__25_Jun_2012_13_33_18_+1000_wKb8ulSpM+VLtTPa"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	=?UTF-8?B?IkJqw7hybiBNb3JrIg==?= <bjorn@mork.no>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from haggis.pcug.org.au ([203.10.76.10]:59403 "EHLO
	members.tip.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752654Ab2FYDdd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Jun 2012 23:33:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Signature=_Mon__25_Jun_2012_13_33_18_+1000_wKb8ulSpM+VLtTPa
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
drivers/net/usb/qmi_wwan.c between commit b9f90eb27402 ("net: qmi_wwan:
fix Gobi device probing") from the net tree and various commits from the
net-next tree.

I am not sure how to fix this, but the comments in the net tree commit
implied that it would be placed in the 3.6 code, so I just used the
version of this file from the net-next tree.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Mon__25_Jun_2012_13_33_18_+1000_wKb8ulSpM+VLtTPa
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJP59v+AAoJEECxmPOUX5FEfnoP/1wJ2+5sV9ul1lqwnD+VOvtv
U10dLgP6mpa0b5MU7dduiYqZ6UJ5CTQr3ELzDFfkwHtRqsYl+pjZTVIPTQL1JvE1
RLUSkwB6QW/vjz3DsBGaecyS3p9ChO4hiMNUWOigEncTbD8SpbKjFZMRHe4rMLcM
pbuT+10zzX1iY++kyyzAZgU9yZJ5s6lv/cnKtNagu1U5toYRwlTDryxT+9sZBD1Z
Si/KxM0onHCynRvxsY41nYP4vX9aFfVFp/xjfXOpEB00rcOelmlibDOY/gLY7BAS
19R0Nu1ABDS8WD0awyoXdwgCyXDsyWtgfmE0KGRKi0HPoNxAPHa6uRM1bZw57Fj6
RcVzguQ8XewotdK66I1PG2I/QPPf0SdU/Jv2hjAgGOJsvQuUpBsFShZmbN3KafgF
5nvnXKaoO7fwu9che8240Gg3gQM75NeTPGnHhXRRhFESw1wLRA11ckuK7SbAQ/op
KZaLvGQaAT2Nd7YzHoLzdwH+1+CiQgdHVX2lUDKW+biPx+Ni8W4iDEnq5eEci/X7
r1dakiX0IxOZuHo1TaK6yYUJVQKvSXy9eSfuscxvz+TKA18bH+ktZusM0AJ871ET
la1Gx/Mb232Z/fkadq7llqvJky3ZlTiR+dlam5HEwiHGSnL72ROdgpXxNi5yGCDW
S5+sw9R6SAgFcFDeQhJE
=dYqs
-----END PGP SIGNATURE-----

--Signature=_Mon__25_Jun_2012_13_33_18_+1000_wKb8ulSpM+VLtTPa--
