From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: 2.6.29-git13: Reported regressions from 2.6.28
Date: Wed, 8 Apr 2009 00:24:19 +0200
Message-ID: <200904080024.20489.rjw@sisk.pl>
References: <n4io5wq70ZO.A.gzG.rFn2JB@chimera> <Pine.LNX.4.64.0904071256110.12253@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Mikael Pettersson <mikpe@it.uu.se>
To: "Ilpo =?iso-8859-1?q?J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:56195 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759833AbZDGWYY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Apr 2009 18:24:24 -0400
In-Reply-To: <Pine.LNX.4.64.0904071256110.12253@wrl-59.cs.helsinki.fi>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 07 April 2009, Ilpo J=E4rvinen wrote:
> On Mon, 6 Apr 2009, Rafael J. Wysocki wrote:
>=20
> > Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12867
> > Subject		: 2.6.29-rc7 broke r8169 MAC on Thecus n2100 ARM board
> > Submitter	: Mikael Pettersson <mikpe@it.uu.se>
> > Date		: 2009-03-09 20:29 (29 days old)
> > References	: http://marc.info/?l=3Dlinux-kernel&m=3D123663065403760=
&w=3D4
> > Handled-By	: Francois Romieu <romieu@fr.zoreil.com>
>=20
> I think this was fixed in the mainline by revert
> ea8dbdd17099a9a5864ebd4c87e01e657b19c7ab.

Thanks, closed.

Rafael
