From: "Hesse, Christian" <mail@earthworm.de>
Subject: Re: [ANNOUNCE] d80211 based driver for Intel PRO/Wireless 3945ABG
Date: Sat, 10 Feb 2007 15:25:48 +0100
Message-ID: <200702101525.56820.mail@earthworm.de>
References: <45CCE3CA.4050904@linux.intel.com> <200702101424.00156.mail@earthworm.de>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart4019170.1c3ci8dBOU";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
	ipw3945-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: James Ketrenos <jketreno@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lugor.de ([212.112.242.222]:57227 "EHLO solar.vpn.lugor.de"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932300AbXBJOZ6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 10 Feb 2007 09:25:58 -0500
In-Reply-To: <200702101424.00156.mail@earthworm.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart4019170.1c3ci8dBOU
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Saturday 10 February 2007 14:23, Hesse, Christian wrote:
> On Friday 09 February 2007 22:12, James Ketrenos wrote:
> > We are pleased to announce the availability of a new driver for the
> > Intel PRO/Wireless 3945ABG Network Connection adapter.
>
> Wow, great news on this rainy saturday! ;-)
>
> The driver works perfectly, I'm writing this mail via wireless link.
> However there are two things to note:
>
> The driver generates two network devices. The second one is for promicious
> mode? Is there any chance to disable the interface? ifrename renamed the
> wrong one to wlan0 and I had to tell my system to use eth1 for the wirele=
ss
> connection.
>
> Second problem is that I can't unload the module. I get the message "FATA=
L:
> Module iwlwifi is in use." even if both interfaces are down.

Oh, I forgot one note: "make patch_kernel" is terribly broken. Any chance t=
o=20
get this fixed soon?
=2D-=20
Regards,
Chris

--nextPart4019170.1c3ci8dBOU
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBFzdX0lZfG2c8gdSURArNvAKDqpZwP8EkjphorY1tka+GEmFYKJQCgv8Bp
+nNB/GDp0HYCL9nwxjnxupk=
=Gd7L
-----END PGP SIGNATURE-----

--nextPart4019170.1c3ci8dBOU--
