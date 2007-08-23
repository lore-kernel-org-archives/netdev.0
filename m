From: Prakash Punnoor <prakash@punnoor.de>
Subject: Re: [2.6.20.17 review 35/58] forcedeth bug fix: realtek phy
Date: Thu, 23 Aug 2007 17:50:41 +0200
Message-ID: <200708231750.45257.prakash@punnoor.de>
References: <20070822083844.%N@1wt.eu> <20070822204225.GD14132@1wt.eu> <20070822230526.GC32121@suse.de>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2544282.4zfNHyCUiP";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Willy Tarreau <w@1wt.eu>, linux-kernel@vger.kernel.org,
	stable@kernel.org, Ayaz Abdulla <aabdulla@nvidia.com>,
	netdev@vger.kernel.org
To: Greg KH <gregkh@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-in-04.arcor-online.net ([151.189.21.44]:37116 "EHLO
	mail-in-04.arcor-online.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758673AbXHWPvH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2007 11:51:07 -0400
In-Reply-To: <20070822230526.GC32121@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart2544282.4zfNHyCUiP
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On the day of Thursday 23 August 2007 Greg KH hast written:
> On Wed, Aug 22, 2007 at 10:42:25PM +0200, Willy Tarreau wrote:
> > On Wed, Aug 22, 2007 at 08:15:03PM +0200, Prakash Punnoor wrote:
> > > Hi,
> > >
> > > even if Greg is waiting for some special invitation
> > > (http://lkml.org/lkml/2007/8/14/229), I suggest putting this patch by
> > > Ayaz on top:
> > >
> > > http://lkml.org/lkml/2007/8/10/296
> >
> > That's what I prepare first, but then noticed it's not in mainline.
> >
> > > Perhaps Ayaz wants to give Greg the clarification he needs... :sigh:
> >
> > He should, as the fix is not in mainline either :-(
> > I don't think Greg asks for specific clarification, just a plain patch
> > with a short commit log on its own which does not include remains of
> > older mails.
>
> Exactly, that is what I am waiting for.
>
> And also I need the change to go into mainline first, as we can not
> diverge with the -stable releases.

Can we get that into mainline then? I haven't seen forcedeth in MAINTAINERS=
,=20
so I added netdev to the cc list.

bye,
=2D-=20
(=B0=3D                 =3D=B0)
//\ Prakash Punnoor /\\
V_/                 \_V

--nextPart2544282.4zfNHyCUiP
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.6 (GNU/Linux)

iD8DBQBGzazVxU2n/+9+t5gRArFSAKDkCgJUrlJ4JjO4RCApyTEvR5CZbwCg70iK
BKkFiX1CidBJVjNdZ95ztCc=
=HVOh
-----END PGP SIGNATURE-----

--nextPart2544282.4zfNHyCUiP--
