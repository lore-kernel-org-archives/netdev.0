From: Erik Mouw <mouw@nl.linux.org>
Subject: Re: Support for Intel 82562V-2?
Date: Mon, 6 Aug 2007 21:54:07 +0200
Message-ID: <20070806195407.GB18130@gateway.home>
References: <20070806163819.GA18130@gateway.home> <BD524EA7912ED5469DFD0BAEF6BC752F0256D088@orsmsx411.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="TRYliJ5NKNqkz5bu"
Cc: netdev@vger.kernel.org
To: "Allan, Bruce W" <bruce.w.allan@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-vbr2.xs4all.nl ([194.109.24.22]:3138 "EHLO
	smtp-vbr2.xs4all.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758213AbXHFTyS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Aug 2007 15:54:18 -0400
Content-Disposition: inline
In-Reply-To: <BD524EA7912ED5469DFD0BAEF6BC752F0256D088@orsmsx411.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--TRYliJ5NKNqkz5bu
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Aug 06, 2007 at 10:54:56AM -0700, Allan, Bruce W wrote:
> While that is a "10/100 network connection", it is actually a GigE MAC
> with a 10/100 PHY and will be supported by the e1000e driver that is
> currently in the process of final cleanup before getting into the
> upstream kernel.

Ah right, a GigE NIC in disguise... I read that thread a couple of days
ago but didn't associate it with this particular hardware.

> If you must use it now, you can grab the latest out-of-tree version of
> the e1000 driver from http://e1000.sf.net which has support for that
> device.  There are no plans for adding support for this device to the
> in-tree e1000 driver.

Thanks, that one works great.


Erik

--=20
They're all fools. Don't worry. Darwin may be slow, but he'll
eventually get them. -- Matthew Lammers in alt.sysadmin.recovery

--TRYliJ5NKNqkz5bu
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFGt3xf/PlVHJtIto0RAkMLAJ9RrOUt7NynIrZJBYYlsaDYTnj70QCdGJxL
cprOx7+Vv3Ka6V1S71o2Zkc=
=OJp6
-----END PGP SIGNATURE-----

--TRYliJ5NKNqkz5bu--
