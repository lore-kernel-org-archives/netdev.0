From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 0/4][pull request] Intel Wired LAN Driver Updates
Date: Mon, 07 May 2012 00:12:58 -0700
Message-ID: <1336374778.2386.1.camel@jtkirshe-mobl>
References: <1336221493-913-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <20120506.132513.36895742709809565.davem@davemloft.net>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-Ct7zcx/iOHzcQUcwnybn"
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:34853 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755339Ab2EGHNU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 May 2012 03:13:20 -0400
In-Reply-To: <20120506.132513.36895742709809565.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Ct7zcx/iOHzcQUcwnybn
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2012-05-06 at 13:25 -0400, David Miller wrote:
> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Sat,  5 May 2012 05:38:09 -0700
>=20
> > This series of patches contains updates for e1000e and ixgbe.
> >=20
> > NOTE- The ixgbe patch can and probably should be applied to
> > David Miller's net tree as well.
> >=20
> > The following are changes since commit bd14b1b2e29bd6812597f896dde06eaf=
7c6d2f24:
> >   tcp: be more strict before accepting ECN negociation
> > and are available in the git repository at:
> >   git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next maste=
r
>=20
> No new changes there?
>=20
> [davem@drr net-next]$ git pull git://git.kernel.org/pub/scm/linux/kernel/=
git/jkirsher/net-next master
> From git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next
>  * branch            master     -> FETCH_HEAD
> Already up-to-date.

Sorry Dave, I thought I had pushed the changes but it appears I did not.
I have rectified that and now my net-next tree contains the four
patches.

--=-Ct7zcx/iOHzcQUcwnybn
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJPp3X6AAoJEOVv75VaS+3O0qAQAJ4scKLZRRfPHwTt8l/lWiaj
ontM7pUWBESl+9mC2kskTB532EUB0RFtaVcoeiP15nkz/gp1C7zX450JVmiurZo0
BOz/xMq2kC82ZvyoM8CXctUQMKSt7qrVy0fFdtmtRP4U7P3bjxzwAILCCxChHQ21
RlrVKEsJomSjfiZF9s5UaNZ2kdfALgjLgHR/9rrmRn/hJTpAoq+bBBd3U1Jmqpt8
+UQevawA1OydIcv5sVL95Id86wuLtB7GI1VUC/gPrOlut5b64UfA2Uq2/ZBK7vV9
wTKLpu/8pt1xGpPg5dowhp8F9sLCnr7ZMzTm5kmMIJi9KNTbN47Bbb+ce8A1j6yx
+Oz//zlsuV7O1ttAEhh88JbXqY78LQSSHYVCv6TDjR8lxNrIUp+aRPp1QJy4610G
JXR2erlmuIWz1oSTvFnIwaD0rVTGaBrfRB+4KTbaJbDEm9/shJ/Gh+9oh6GZxnNw
rEg4rvkFp93FQV04len1iwaCSLyhJY02vIcNawcameKYff3i+3cmLR4zVS9LHy/B
JRx/5bgorgWeV4EZCKPUBtxUvyGtXyXCidTgQO9qVOVQHsYufXA8T7c6O9z6WJLh
K94e3SWfw1ce+ohdDsBXGkz5zAXq74gJ3ousz7hrqpWQfCgZ+HMynSAfbZueOe7l
116+ZzR2fRAvv/KLBOro
=twGV
-----END PGP SIGNATURE-----

--=-Ct7zcx/iOHzcQUcwnybn--
