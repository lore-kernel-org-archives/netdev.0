From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next v2 11/71] ni5010: Move the Racal-Interlan (Micom)
 driver
Date: Sun, 31 Jul 2011 12:20:18 -0700
Message-ID: <1312140019.20837.125.camel@jtkirshe-mobl>
References: <1312082850-24914-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1312082850-24914-12-git-send-email-jeffrey.t.kirsher@intel.com>
	 <20110731165702.GA6334@rhlx01.hs-esslingen.de>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-a+Lzx9dEswAfLaDwlxda"
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	Jan-Pascal van Best <janpascal@vanbest.org>
To: Andreas Mohr <andi@lisas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:58987 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751370Ab1GaTUU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 31 Jul 2011 15:20:20 -0400
In-Reply-To: <20110731165702.GA6334@rhlx01.hs-esslingen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-a+Lzx9dEswAfLaDwlxda
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2011-07-31 at 09:57 -0700, Andreas Mohr wrote:
> Hi,
>=20
> On Sat, Jul 30, 2011 at 08:26:30PM -0700, Jeff Kirsher wrote:
> > Moves the Racal-Interlan driver into drivers/net/ethernet/racal/ and
> > make the necessary Kconfig and Makefile changes.
>=20
> Acked-by: Andreas Mohr <andi@lisas.de>
>=20
> ---
>=20
> Sorry, I had intended to reply to the original RFC,
> but due to vacation backlog that got swept under the rug.
>=20
> Since it's a simple move it seems to be fine.
>=20
> One minor nit, however: since ni5210 (as seen in some other patch)
> got moved to its respective NON-racal location (due to using a specific
> chipset),
> a short Kconfig addition explaining the whereabouts of ni5210
> (and perhaps some other OEM chipset Racal cards?) would be useful.

Sounds good, would you be up for sending my a patch against my tree and
I can fold it into my current patchset?  Or do you want to just send a
patch later on?  I know what your intention is, I am just not sure how
you would like it to show up in the Kconfig.

My git tree with this patch series applied is:
git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-organize

>=20
> Thank you for the probably long overdue cleanup of drivers/net/
> into something more specific and thus much more easy on the eye :)

Thanks, it is nice to hear.

>=20
> Andreas Mohr



--=-a+Lzx9dEswAfLaDwlxda
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJONaryAAoJECTsCADr/EWUUacIAIZEdxx9zR+ue66jwn8rCNTp
IrpMOur/nXrHtVNw079vV9Jz61L5xm4pSwUX38EPkiYTxwPn9NkStCzrmf+KItGv
Kl7GzF23ArxUQCAlbq8DIL8/xzQiVA/CaiJPsxKS66HeJoynFFpm9132H/iFXBTT
wLBCt7LP0EkgLvCMg3Hs6TWlaj7q20kSkYj2Jp5klJ1zPf4C7+P4KsDAOZoB6xMw
uaO4KftD+P8u0K0VCpZw35jgiu7oPBIjTjfM9vmqS2ex1tpVmZgTASVjqcd45hFB
Y4+d5LD+zhp7217o3rQkrwzlcFmYyfe/KF22EOLq5Bbs/hlfMh1qLQi5nwaKwfY=
=aGKa
-----END PGP SIGNATURE-----

--=-a+Lzx9dEswAfLaDwlxda--

