From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 00/13][pull request] Intel Wired LAN Driver Updates
Date: Sun, 22 Jul 2012 14:39:53 -0700
Message-ID: <1342993193.23226.0.camel@jtkirshe-mobl>
References: <1342912142-11130-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <20120722.122405.1220712908232591030.davem@davemloft.net>
	 <20120722.123733.1898891964192153293.davem@davemloft.net>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-BMRYORnD4bKPtjJ5tTCd"
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:20296 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752626Ab2GVVkF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Jul 2012 17:40:05 -0400
In-Reply-To: <20120722.123733.1898891964192153293.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-BMRYORnD4bKPtjJ5tTCd
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2012-07-22 at 12:37 -0700, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Sun, 22 Jul 2012 12:24:05 -0700 (PDT)
>=20
> > From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > Date: Sat, 21 Jul 2012 16:08:49 -0700
> >=20
> >> This series contains updates to ixgbe and ixgbevf.
> >>=20
> >> The following are changes since commit
> 186e868786f97c8026f0a81400b451ace306b3a4:
> >>   forcedeth: spin_unlock_irq in interrupt handler fix
> >> and are available in the git repository at:
> >>   git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next
> master
> >=20
> > Pulled, thanks Jeff.
>=20
> Can you guys actually build test this stuff?=20

I did, but it appears I did not have PCI_IOV enabled.  That was my bad,
sorry.

--=-BMRYORnD4bKPtjJ5tTCd
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJQDHMpAAoJEOVv75VaS+3OyEsP/3eEqkhaP8DJ/FhSPKv4rEQv
YFa3WwEiXndA3KCTNDyd+dGquF0XWo1G3epAI4/UdDiKPuLzsIS7mTLpbJhNRvwT
NhwefsfsJQG+Eh9xvS3N8bpB/nvSIWBbx0bswF3u1NxzZonf7q7EKxn4XsfHUari
6v71aNIsc4wHQ7+vKqO6mqFhGe4IA6MF315BDYFstfDofI4KBvSFrUrECMOdRP8h
7QDqgAEEMzLfJ+R/17M3Iw0MhIkSGrDML/woe8i/er+s4XqkDJD/K+n0QRWHMKWp
ooz5fG9vdvDDfksngNSeCbqszWDNEJEQ6qwn1jB3Abrig21fQIMFeVMtjDw+REle
rRo/vqeHX9St9s70WMq1mffxNecnuU6qNBPkiKVrEU3lK6dess5BenBQya6ifHgk
0tDsCP2hI/GXse2RODZkaIA19hV8RQy8frXEfcbJMlLQvPaIqJc/KyqPWBY0ah68
uufjWEepVuxiQ4BcJoigF0DPwu6u6Y5w82I1vUDoz37x8s6ZrErrKEC9ZXpz5emF
WliO1UWcWMrn+SE8wKP9Wl57DsHHU7TV5oy74c+jtjnKA7RPdw3vk+fuFmXK7VVr
XklkfOksLandKu5su1YeBdVEPWyMcZxFF8L2AwVoQOlVwEBCbMpoBW8nw4ZsNiT4
GBkguq86Ynpi6bQUqrRX
=zMv/
-----END PGP SIGNATURE-----

--=-BMRYORnD4bKPtjJ5tTCd--
