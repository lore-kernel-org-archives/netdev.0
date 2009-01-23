From: Robert Schwebel <r.schwebel@pengutronix.de>
Subject: Re: [PATCH] am79c961a: fix spin_lock usage
Date: Fri, 23 Jan 2009 21:43:18 +0100
Message-ID: <20090123204318.GO29067@pengutronix.de>
References: <1232663382-10503-1-git-send-email-u.kleine-koenig@pengutronix.de> <20090122223412.GB8137@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Uwe =?iso-8859-15?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>,
	linux-arm-kernel@lists.arm.linux.org.uk,
	Roel Kluin <12o3l@tiscali.nl>,
	Steven Rostedt <srostedt@redhat.com>, netdev@vger.kernel.org
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:49870 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752797AbZAWUnb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2009 15:43:31 -0500
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
>
> Don't care about gcc 4.3.2 - it's broken for the ARM architecture.

Any pointer?

rsc
--=20
Pengutronix e.K.                           |                           =
  |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0  =
  |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-555=
5 |
