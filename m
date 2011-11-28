From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: (repost) vhost tree for linux-next
Date: Tue, 29 Nov 2011 10:36:23 +1100
Message-ID: <20111129103623.50fb58ac94d90f11c675fff5@canb.auug.org.au>
References: <20111124203843.GC4873@redhat.com>
	<20111127124816.GA23270@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Tue__29_Nov_2011_10_36_23_+1100_DZZuYPv9K9S6e_gn"
Cc: linux-next@vger.kernel.org, linux-pci@vger.kernel.org,
	netdev@vger.kernel.org, linux-scsi@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from calzone.tip.net.au ([203.10.76.15]:38119 "EHLO
	calzone.tip.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755354Ab1K1Xgd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2011 18:36:33 -0500
In-Reply-To: <20111127124816.GA23270@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Signature=_Tue__29_Nov_2011_10_36_23_+1100_DZZuYPv9K9S6e_gn
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Michael,

On Sun, 27 Nov 2011 14:48:17 +0200 "Michael S. Tsirkin" <mst@redhat.com> wr=
ote:
>
> I normally merge things through Dave, Rusty, Jesse or Jens,
> not directly to Linus. However, sometimes there's a large change
> (for example, my recent RFC for pci_iomap changes)
> where estimating how it interacts with other platforms and planned
> changes in the next kernel would be beneficial.
>=20
> For this purpose, it would be helpful if my tree were added to linux-next.
> The tree is:
> git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git linux-next
>=20
> Could you do this please?

I have added this tree from today with just you as the contact.

Thanks for adding your subsystem tree as a participant of linux-next.  As
you may know, this is not a judgment of your code.  The purpose of
linux-next is for integration testing and to lower the impact of
conflicts between subsystems in the next merge window.=20

You will need to ensure that the patches/commits in your tree/series have
been:
     * submitted under GPL v2 (or later) and include the Contributor's
	Signed-off-by,
     * posted to the relevant mailing list,
     * reviewed by you (or another maintainer of your subsystem tree),
     * successfully unit tested, and=20
     * destined for the current or next Linux merge window.

Basically, this should be just what you would send to Linus (or ask him
to fetch).  It is allowed to be rebased if you deem it necessary.

--=20
Cheers,
Stephen Rothwell=20
sfr@canb.auug.org.au

Legal Stuff:
By participating in linux-next, your subsystem tree contributions are
public and will be included in the linux-next trees.  You may be sent
e-mail messages indicating errors or other issues when the
patches/commits from your subsystem tree are merged and tested in
linux-next.  These messages may also be cross-posted to the linux-next
mailing list, the linux-kernel mailing list, etc.  The linux-next tree
project and IBM (my employer) make no warranties regarding the linux-next
project, the testing procedures, the results, the e-mails, etc.  If you
don't agree to these ground rules, let me know and I'll remove your tree
from participation in linux-next.

--Signature=_Tue__29_Nov_2011_10_36_23_+1100_DZZuYPv9K9S6e_gn
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBCAAGBQJO1Br3AAoJEECxmPOUX5FE5BMP/RvTlwmnqb+v6CXWp3EGteq/
uMSfJQie9u1Jir7hfaNFdkCutHSfESyXBwisV4UcQTiWtal6+MxGLaQihsOxzuFY
IiTn8ShxQFNtq07klCk4bV/PW3qN0JQUA1huasDZp2ZY2DuO+KQw+4tdic77lXlJ
fnZjIFuj80nuMKCqXFd7Vx89a9jW3EPfvgMpK+phbAcO2uhqpAIRQ7mRsLXWlUJ3
81xeOb1rSRqfPJDlfGuP7JOflTbyW96Y3C9Dg18Qf93PvU97N4qfZXsROicD6nbH
DxoFBrD4wVWUh7Oyr8RoCCA0cQnrVmI9Z4H0oLgF1k7MiLPiDMuo9YxpozfD9fjF
v4j+fLVikziNC4Sy+IRoKC/T0EKL5zZgt0sSo5DlSErrQ4Foa6IwmOJtATRx4Ae8
mJOU/3wYB/4sxALh6z+F1oBuzWqn7WFt7WI3p3WHOSy/IEOLYu6flQIA93B99Oum
bAGCTTaHh1BdFBd5aAnCS9VDhXO+SvlVicLs75+vgegRcc1u7T5DI6uPOYRNa8qE
Em+2aHY1iOTxZrjf4rMTKGzv75AklJgPsE+uOpBScG+dglKWbiC/Jw+G6q6Bt9r0
wfH2hygHr/Mtl5SnEy/PXbUSt1rqwX4TXOElSuSLK1/OkMIz+Y5V3+lfPJC5veBz
6f1dQMF1nXj+g6coPgDA
=tO7r
-----END PGP SIGNATURE-----

--Signature=_Tue__29_Nov_2011_10_36_23_+1100_DZZuYPv9K9S6e_gn--
