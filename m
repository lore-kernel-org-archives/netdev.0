From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 00/10][pull request] Intel Wired LAN Driver Update
Date: Tue, 23 Aug 2011 19:34:28 -0700
Message-ID: <1314153269.2128.238.camel@jtkirshe-mobl>
References: <1313911761-11709-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <20110823.154548.1870719393143742013.davem@davemloft.net>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-1xA7vHtR4zbzXn4iVGPU"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:60431 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754738Ab1HXCea (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Aug 2011 22:34:30 -0400
In-Reply-To: <20110823.154548.1870719393143742013.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-1xA7vHtR4zbzXn4iVGPU
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2011-08-23 at 15:45 -0700, David Miller wrote:
> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Sun, 21 Aug 2011 00:29:11 -0700
>=20
> > The following series contains updates to ixgbe.
> >=20
> > The following are changes since commit ca1ba7caa68520864e4b9227e67f3bbc=
6fed373b:
> >   Merge branch 'master' of master.kernel.org:/pub/scm/linux/kernel/git/=
jkirsher/net-next
> > and are available in the git repository at:
> >   master.kernel.org:/pub/scm/linux/kernel/git/jkirsher/net-next master
>=20
> Alexander says he is going to respin patch #3, so I'm dropping this and
> waiting for the next submission.

I agree, I have been following the thread.  I know know Alex will work
on re-working the patch, in the meantime I will review the ixgbe-patches
ready to be submitted which are not affected by the changes in patch 3
and push those while I await.

--=-1xA7vHtR4zbzXn4iVGPU
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJOVGM0AAoJECTsCADr/EWU0uMH/2aTysskujMCJDjLMgh/GTIq
A2s9Ic/+JHmAq6G5rP0V60i9CPykhSaadpuzMlzXuZXt5YhY/M522FYK/+hMDTLW
MI9gMOKSwRmfTgxfn4erR6CzGpb/OydN9IW/ixoqpWCpBARDM63IcR6egyx4zLjX
y/5BOW9yUGDaQXLNSISG80ZR/IzCWcifAvXCGjk2hvP2VwImsqCw5IGsMSZaxuWd
j4kb82s7F7xQhF2ZAhA6wNQ/qpz5q8JddtNNTlqYk07EiPtBMw+kdL7kLlOL3EUm
wClsf788ia4fuX9xKuPpQqxfk8QBMGpPCgCNar2y8nbChcfhYAMIBQsrEtXtscs=
=Wjl4
-----END PGP SIGNATURE-----

--=-1xA7vHtR4zbzXn4iVGPU--
