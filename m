From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: Re: [PATCH 02/14] net/fec: release mem_region requested in probe
 in error path and remove
Date: Fri, 11 Feb 2011 12:03:39 +0100
Message-ID: <20110211110339.GH27982@pengutronix.de>
References: <1297420342-17739-1-git-send-email-u.kleine-koenig@pengutronix.de>
 <1297420342-17739-2-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Shawn Guo <shawn.guo@freescale.com>, kernel@pengutronix.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:44806 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755261Ab1BKLDm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Feb 2011 06:03:42 -0500
Content-Disposition: inline
In-Reply-To: <1297420342-17739-2-git-send-email-u.kleine-koenig@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Fri, Feb 11, 2011 at 11:32:10AM +0100, Uwe Kleine-K=F6nig wrote:
> Noticed-by: Lothar Wa=DFmann <LW@KARO-electronics.de>
I changed that to Reported-by: in this and the other patches.
(this was Reported-by: Wolfram Sang via irc).  The updated patches can
be found at

	git://git.pengutronix.de/git/ukl/linux-2.6.git fec

=2E

Best regards
Uwe

--=20
Pengutronix e.K.                           | Uwe Kleine-K=F6nig        =
    |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |
