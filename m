From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 1/2] igb: Support sending custom Ethernet FCS.
Date: Mon, 05 Mar 2012 17:34:42 -0800
Message-ID: <1330997682.2817.1.camel@jtkirshe-mobl>
References: <1330997441-13324-1-git-send-email-greearb@candelatech.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-MIli9D//3sbYKMj/Gb4R"
Cc: netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:43004 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758066Ab2CFBfy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Mar 2012 20:35:54 -0500
In-Reply-To: <1330997441-13324-1-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-MIli9D//3sbYKMj/Gb4R
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2012-03-05 at 17:30 -0800, greearb@candelatech.com wrote:
> From: Ben Greear <greearb@candelatech.com>
>=20
> Including bad FCS, used generate frames with bad FCS
> to test other system's handling of RX of bad packets.
>=20
> Signed-off-by: Ben Greear <greearb@candelatech.com>
> ---
> :100644 100644 fda8247... e4058ac...
> M  drivers/net/ethernet/intel/igb/igb_main.c
>  drivers/net/ethernet/intel/igb/igb_main.c |    4 ++++
>  1 files changed, 4 insertions(+), 0 deletions(-)=20

I have added these as well to my queue, thanks Ben!

--=-MIli9D//3sbYKMj/Gb4R
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJPVWmyAAoJEOVv75VaS+3O7VgP/33Gf3DYatfOAncWgr5hYWyO
VTFl2nzX/9zoLsbUX9pGhCsytIoSOfU70GiOxH1kTpHg+zJn/rp3kKX7nO1ZZTHP
wZSwwuol/w9cbDyfpmU7LOxUCRCsEsPfgXuCWUVYwnij2bKUZ5QfGAsYCAeHZdId
BuD6Vkc/HEm4nfT59e2lqaUsnRg4FmsuR8pcg2AsxeZ5TIRvJvDj9u3kyT8b273b
7hrV+GvtS4NWhkczkrj0i6N8JEY8XqYbFtAldmRdY2QCFLx7tRTK31w6OLtpH7cU
3Mly+JKH2xUM4srqqNeQokkTHPK8xr7+y1VVqC7k85cFvipImEEMSF+PPVZkluMt
sqJ+AFiUddPsz+SN7GvxwsQ2RMwNoq8tL+TTO+wrJcAV37lySc0njgPM7J5qjw0z
6CotSGDs/x6KOv7gdZMDMMsKvA8BKZPsy/fInt9Jo6NSrkkrqc4zokUUBOYwjBK5
/nasXXWsjktNsVQoN+bX3KFa7ib0OigrpbOiqw7H9MT5yuNMhR6jb5MCjDL0vnnk
qmlSwA8NQ+54lbctasSRcrpz/FXmB2VT0WlRz6PbopbjEwXiSFHVqWRgbrthp7MW
ko4oU+o/x9PG47DMTnxFPwymxjqPuJ+fLBTxw0VgK/6xGtLV8lbsuEqFKcrNbL+6
a5RMgKYS6Ci/VO+Q3j0I
=/JRi
-----END PGP SIGNATURE-----

--=-MIli9D//3sbYKMj/Gb4R--
