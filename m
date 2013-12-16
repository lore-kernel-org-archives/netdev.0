From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [net-next 1/1] linux-firmware: 3.2.23.0 Firmware for Brocade
 Adapters
Date: Mon, 16 Dec 2013 00:14:33 +0000
Message-ID: <1387152873.2803.8.camel@deadeye.wl.decadent.org.uk>
References: <1386482407-984-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-MhlaJl0yD0ZAf6T2Gq/p"
Cc: dwmw2@infradead.org, netdev@vger.kernel.org,
	linux-scsi@vger.kernel.org
To: Rasesh Mody <rmody@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:45010 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750831Ab3LPAOn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Dec 2013 19:14:43 -0500
In-Reply-To: <1386482407-984-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-MhlaJl0yD0ZAf6T2Gq/p
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2013-12-07 at 22:00 -0800, Rasesh Mody wrote:
> This is the firmware patch for Brocade 3.2.23.0 BFA and BNA drivers.
>=20
> Signed-off-by: Rasesh Mody <rmody@brocade.com>
> ---
>  WHENCE            |   3 +++
>  cbfw-3.2.3.0.bin  | Bin 0 -> 414016 bytes
>  ct2fw-3.2.3.0.bin | Bin 0 -> 583688 bytes
>  ctfw-3.2.3.0.bin  | Bin 0 -> 538712 bytes
>  4 files changed, 3 insertions(+)
>  create mode 100644 cbfw-3.2.3.0.bin
>  create mode 100644 ct2fw-3.2.3.0.bin
>  create mode 100644 ctfw-3.2.3.0.bin
[...]

This patch seems to have been truncated in transit:

$ git am -s ~/tmp/\[net-next_1_1\]_linux-firmware\:_3.2.23.0_Firmware_for_B=
rocade_Adapters.mbox
Applying: linux-firmware: 3.2.23.0 Firmware for Brocade Adapters
error: corrupt binary patch at line 13542: znHIKNgBV5>FJqIQgo|#@us1Wq_D(J

Please re-send (but not to the mailing lists; it's pointless to send
binaries there).

Ben.

--=20
Ben Hutchings
Lowery's Law:
             If it jams, force it. If it breaks, it needed replacing anyway=
.

--=-MhlaJl0yD0ZAf6T2Gq/p
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIVAwUAUq5F6ee/yOyVhhEJAQri9w/9EaUkIjzaVo9ZJNDUUpvnkg5BU+9HtWnN
AqW053xdNEOiwkxFQOMCDaDhsddDC9acqF334FP/Xl1Eb6JDKj/IJL/FkcmeXSWG
oySFUlrNTTEFOTi0ajiQyMvHNY5bY74hGsHD1jX/56jqLw1leHD5eCBDxvtM8Pd5
r5ITH1lc4JmAC9ACVzgLU+V8O2kqVCcyw5Owtc4lgFhOPx9KkKsSx9mNQWe9n6rX
xP+jKx+4/CsbEFkWrMmPjIT/prfWo0opZyGnKsBj/jqM9s0HyctwwPJzqeCs6a+Y
nj8xQ3pbqP8UpQBrwzKsjMWRb/RbYZgMT1sGeFc6tHYBReSNZwdg+OMrHrs0GhT1
9qaMStKvbOm1miLkDY3kR8pbktu3bFn9uhZiLzET/K3HmgKL3jXqol6RcucUeydt
UHr+qhgZxIOUWWU3JeR8TKicjrDc+F18tcSCIj9cezntB1B9m9Gwyyu7ossS2vw9
9r74RYXN1798FKyNc/F7080gnORvUoBnnLyTEjPEey89F5/lzS4jCFMKNmeGEVWx
cp5p3MN8meOZDTZrqzarfpa9bZ4VGvXrbU/gKMkl4PC9LEbNPS6mIX18tiGxKQd9
rXzPD9FmGp1nTrdJerHPexmfPK1TjVMIXQx61HmzkydXR2QXxhuyQAHixI6dkxJ1
ICKcgtAGtY0=
=oaoF
-----END PGP SIGNATURE-----

--=-MhlaJl0yD0ZAf6T2Gq/p--
