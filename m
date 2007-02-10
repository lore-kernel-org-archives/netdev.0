From: "Hesse, Christian" <mail-8oMOrB1mGocUSW6y5lq3GQ@public.gmane.org>
Subject: Re: [ANNOUNCE] d80211 based driver for Intel PRO/Wireless 3945ABG
Date: Sat, 10 Feb 2007 14:23:55 +0100
Message-ID: <200702101424.00156.mail@earthworm.de>
References: <45CCE3CA.4050904@linux.intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1331304.FZbrcmnoEp";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	ipw3945-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: James Ketrenos <jketreno-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <45CCE3CA.4050904-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

--nextPart1331304.FZbrcmnoEp
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Friday 09 February 2007 22:12, James Ketrenos wrote:
> We are pleased to announce the availability of a new driver for the
> Intel PRO/Wireless 3945ABG Network Connection adapter.

Wow, great news on this rainy saturday! ;-)

The driver works perfectly, I'm writing this mail via wireless link. Howeve=
r=20
there are two things to note:

The driver generates two network devices. The second one is for promicious=
=20
mode? Is there any chance to disable the interface? ifrename renamed the=20
wrong one to wlan0 and I had to tell my system to use eth1 for the wireless=
=20
connection.

Second problem is that I can't unload the module. I get the message "FATAL:=
=20
Module iwlwifi is in use." even if both interfaces are down.
=2D-=20
Regards,
Chris

--nextPart1331304.FZbrcmnoEp
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBFzcdwlZfG2c8gdSURAvfiAJ4nWHv3+Jz4m+AJbHwUN3VVmqOmoQCgktqe
rgsCSbzhtU3sd2uTVluX1K8=
=T5s0
-----END PGP SIGNATURE-----

--nextPart1331304.FZbrcmnoEp--
-
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
