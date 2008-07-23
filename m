From: Peter Palfrader <peter@palfrader.org>
Subject: Re: 2.6.25.6: warn_on_slowpath in tcp_input.c
Date: Wed, 23 Jul 2008 11:03:40 +0200
Message-ID: <20080723090340.GQ18443@anguilla.noreply.org>
References: <20080630230954.GS16698@anguilla.noreply.org> <396556a20806301656ydc44e3ey6deb229ab69904@mail.gmail.com> <20080701073833.GT16698@anguilla.noreply.org> <Pine.LNX.4.64.0807171744130.13775@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Adam Langley <agl@imperialviolet.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>
To: Ilpo =?iso-8859-15?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from anguilla.debian.or.at ([86.59.118.152]:43434 "EHLO
	anguilla.debian.or.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752468AbYGWJDl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2008 05:03:41 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0807171744130.13775@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 17 Jul 2008, Ilpo J=E4rvinen wrote:
> > > > I've had 13 or so of them since upgrading the machine to a 2.6.=
25 kernel
> > > > 20 days ago.
> > > >
> > > > Linux saens 2.6.25.6-dl380 #2 SMP Tue Jun 10 17:54:44 CEST 2008=
 i686 GNU/Linux
>=20
> Thanks for the report, I've been away for a while, thus the late resp=
onse.
> Please update to get this relevant fix and some other TCP fixes (if y=
ou=20
> haven't yet):
>=20
>  releases/2.6.25.7/tcp-fix-skb-vs-fack_count-out-of-sync-condition.pa=
tch
>=20
> ...If you still get them afterwards, please do rereport (and include =
me=20
> as recipient :-)).

Running 2.6.25.11 since a couple of days ago now.  Looking good, thanks=
=2E

--=20
                           |  .''`.  ** Debian GNU/Linux **
      Peter Palfrader      | : :' :      The  universal
 http://www.palfrader.org/ | `. `'      Operating System
                           |   `-    http://www.debian.org/
