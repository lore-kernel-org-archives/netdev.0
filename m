From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: Re: [PATCH] am79c961a: fix spin_lock usage
Date: Thu, 22 Jan 2009 23:44:20 +0100
Message-ID: <20090122224420.GA21204@pengutronix.de>
References: <1232663382-10503-1-git-send-email-u.kleine-koenig@pengutronix.de> <20090122223412.GB8137@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-arm-kernel@lists.arm.linux.org.uk,
	Roel Kluin <12o3l@tiscali.nl>,
	Steven Rostedt <srostedt@redhat.com>, netdev@vger.kernel.org
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:46111 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754381AbZAVWo3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2009 17:44:29 -0500
Content-Disposition: inline
In-Reply-To: <20090122223412.GB8137@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 22, 2009 at 10:34:12PM +0000, Russell King - ARM Linux wrot=
e:
> On Thu, Jan 22, 2009 at 11:29:42PM +0100, Uwe Kleine-K=F6nig wrote:
> > unrelated to that, with arm-linux-gnu-gcc 4.3.2 I get some warnings=
 when
> > compiling am79c961a.c:
>=20
> Don't care about gcc 4.3.2 - it's broken for the ARM architecture.
OK.  I just read that on linux-arm-kernel (up to now I didn't have
problems).  Nevertheless the warnings are valid and the patch fixes a
real (and different) problem.

Best regards
Uwe

--=20
Pengutronix e.K.                              | Uwe Kleine-K=F6nig     =
       |
Industrial Linux Solutions                    | http://www.pengutronix.=
de/  |
