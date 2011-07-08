From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] e1000: always call e1000_check_for_link() on
 e1000_ce4100 MACs.
Date: Fri, 08 Jul 2011 09:21:11 -0700
Message-ID: <1310142072.23477.41.camel@jtkirshe-mobl>
References: <1310044617-22978-1-git-send-email-nschichan@freebox.fr>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-jWVhSJb4sZgMuAiSwR1v"
Cc: "Brandewie, Dirk J" <dirk.j.brandewie@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Florian Fainelli <ffainelli@freebox.fr>,
	"stable@kernel.org" <stable@kernel.org>
To: "nschichan@freebox.fr" <nschichan@freebox.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:29864 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754116Ab1GHQVO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Jul 2011 12:21:14 -0400
In-Reply-To: <1310044617-22978-1-git-send-email-nschichan@freebox.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-jWVhSJb4sZgMuAiSwR1v
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2011-07-07 at 06:16 -0700, nschichan@freebox.fr wrote:
> From: Nicolas Schichan <nschichan@freebox.fr>
>=20
> Interrupts about link lost or rx sequence errors are not reported by
> the ce4100 hardware, leading to transitions from link UP to link DOWN
> never being reported.
>=20
> Signed-off-by: Nicolas Schichan <nschichan@freebox.fr>
> ---
>  drivers/net/e1000/e1000_main.c |   11 +++++++----
>  1 files changed, 7 insertions(+), 4 deletions(-)=20

Thank you for the patch.  I have added the patch to my queue.

--=-jWVhSJb4sZgMuAiSwR1v
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJOFy53AAoJECTsCADr/EWULekH/RhSMPikhywCxjWuyr8nEgjh
QJjPkJBwFpSsPQySNv1UKK9uTeQzDlU6NvJk2tLWznc8N07DnX1TxnGCgzvewigq
z9WhRkVbseV5bBq6w9GWE+x0UwODwmUxbuF2Qwjjmq5oSC1Th6Hj8yTQLSij229x
ZWCEQT5KH9gQmWlBDG8WZC/VDUojjq/UEBOX0ecC0Ukok7qLExZ+qpWFFBA2THY8
tsY2br4YFVgJUd6SJxWnZQEbk/QuaMOhCjBwptE59L2td5I2W+7FMa3j2eRmbazY
omERrP80MJ2EvK0hUJzixVktBV396CY784CF3fQJJDAR6S6vSUG4lN9AY2R/O5o=
=AFoj
-----END PGP SIGNATURE-----

--=-jWVhSJb4sZgMuAiSwR1v--

