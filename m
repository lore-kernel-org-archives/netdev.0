From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: Re: [PATCH] am79c961a: fix spin_lock usage
Date: Fri, 23 Jan 2009 22:15:25 +0100
Message-ID: <20090123211525.GA31893@pengutronix.de>
References: <1232663382-10503-1-git-send-email-u.kleine-koenig@pengutronix.de> <20090122223412.GB8137@n2100.arm.linux.org.uk> <20090123204318.GO29067@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>,
	linux-arm-kernel@lists.arm.linux.org.uk,
	Roel Kluin <12o3l@tiscali.nl>,
	Steven Rostedt <srostedt@redhat.com>, netdev@vger.kernel.org
To: Robert Schwebel <r.schwebel@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:39585 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755429AbZAWVPf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2009 16:15:35 -0500
Content-Disposition: inline
In-Reply-To: <20090123204318.GO29067@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Robert,

On Fri, Jan 23, 2009 at 09:43:18PM +0100, Robert Schwebel wrote:
> On Thu, Jan 22, 2009 at 10:34:12PM +0000, Russell King - ARM Linux wr=
ote:
> > On Thu, Jan 22, 2009 at 11:29:42PM +0100, Uwe Kleine-K=F6nig wrote:
> > > unrelated to that, with arm-linux-gnu-gcc 4.3.2 I get some warnin=
gs when
> > > compiling am79c961a.c:
> >
> > Don't care about gcc 4.3.2 - it's broken for the ARM architecture.
>=20
> Any pointer?
I recently saw:

http://thread.gmane.org/gmane.linux.ports.arm.omap/15540/focus=3D15557
http://thread.gmane.org/gmane.linux.ports.arm.kernel/47539/focus=3D5193=
4

Best regards
Uwe

--=20
Pengutronix e.K.                              | Uwe Kleine-K=F6nig     =
       |
Industrial Linux Solutions                    | http://www.pengutronix.=
de/  |
Peiner Strasse 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-=
0    |
Amtsgericht Hildesheim, HRA 2686              | Fax:   +49-5121-206917-=
5555 |
