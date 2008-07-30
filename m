From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: [patch 12/12] Configure out ethtool support
Date: Wed, 30 Jul 2008 23:52:31 +0200
Message-ID: <20080730235231.71f1b2f9@surf>
References: <200807301939.m6UJd5lT012610@imap1.linux-foundation.org>
	<20080730133727.7774de6a@extreme>
	<20080730224849.59852c68@surf>
	<20080730140136.42223e3c@extreme>
	<20080730233551.76fd38a8@surf>
	<20080730144812.a71156f7.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, jeff@garzik.org, netdev@vger.kernel.org,
	davem@davemloft.net, mpm@selenic.com
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([88.191.46.45]:35894 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759493AbYG3Vwd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2008 17:52:33 -0400
In-Reply-To: <20080730144812.a71156f7.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le Wed, 30 Jul 2008 14:48:12 -0700,
Andrew Morton <akpm@linux-foundation.org> a =C3=A9crit :

> > I understand your point, and I understand that adding many
> > configuration options might not look pretty to everybody (even to
> > me). However, the kernel developers want to keep embedded people
> > using recent versions of the Linux kernel. Unfortunately, the
> > kernel grows release after release (see [1] for a report, for
> > example),
>=20
> There is no [1].

Oops, sorry. [1] should have been
http://free-electrons.com/articles/conferences/elc2008-report#mackall.

=C2=AB
The graph showed an increase of 28% on the kernel size over the last
two and half years. Over the last year, between 2.6.21 and 2.6.25-rc8,
the kernel size of the same allnoconfig has increased from 1.06
megabytes to 1.21 megabytes, a 14% increase.
=C2=BB

Sincerly,

Thomas
--=20
Thomas Petazzoni, Free Electrons
Kernel, drivers and embedded Linux development,
consulting, training and support.
http://free-electrons.com
