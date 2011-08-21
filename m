From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 0/6][pull request] Intel Wired LAN Driver Update
Date: Sat, 20 Aug 2011 19:55:36 -0700
Message-ID: <1313895336.2128.194.camel@jtkirshe-mobl>
References: <1313759486-23575-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <20110820.172919.1482966002228420753.davem@davemloft.net>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-0J6SOuEAxxvbpB7waOy2"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:29350 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753933Ab1HUCzh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Aug 2011 22:55:37 -0400
In-Reply-To: <20110820.172919.1482966002228420753.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-0J6SOuEAxxvbpB7waOy2
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2011-08-20 at 17:29 -0700, David Miller wrote:
> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Fri, 19 Aug 2011 06:11:20 -0700
>=20
> > The following series contains updates to e1000e and ixgbe.
> >=20
> > The following are changes since commit ae1511bf769cafeae5ab61aaf9947a16=
a22cbd10:
> >   net: rps: support PPPOE session messages
> > and are available in the git repository at:
> >   master.kernel.org:/pub/scm/linux/kernel/git/jkirsher/net-next master
>=20
> I had done a net --> net-next merge right before pulling this so there
> was a slight merge conflict, which I think I resolved correctly.
>=20
> Please double-check my work.
>=20
> Thanks.

I knew the e1000e driver version would conflict as soon as a I saw you
updated against net.

e1000e and ixgbe look good, thanks Dave.

--=-0J6SOuEAxxvbpB7waOy2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJOUHOoAAoJECTsCADr/EWUjiAIALFY+RBFwXBL6C74vhCxhjxX
RYEreDDCdrG5cHlN1efiCqODvbImbBbCk79GaBQNrhrEEv2sdGKAbpyqppqSPqhI
CD4mgTqMuGkOh9ktgnNw8NJ9LBX4jmpo2j0Gt+ePDYA9eQWmycPY8CQhextgEPdx
8EPb1VOSgzNP9o8bEbxCSvC/Tk8RXbFX3JqA9RfyYADRp3mDmsQP+HAlfjif9a0c
aH58tPwKPXCpgh2zJfx2AudKN0rvvV+gnUHBVK7ml78cAU2epTIDC+hlHVvkl+dE
LC9xR0gxlIFdfaaA95bJVjrbDL+fvPCHNWvFgZd0v72+QYuRvu+6qPjpUsli6hE=
=ww+n
-----END PGP SIGNATURE-----

--=-0J6SOuEAxxvbpB7waOy2--

