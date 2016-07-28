From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: Re: [PATCH 0/2] net: davinci_cpdma: reduce latency on -rt
Date: Thu, 28 Jul 2016 14:12:28 +0200
Message-ID: <20160728121228.GK5629@pengutronix.de>
References: <1469534545-14478-1-git-send-email-u.kleine-koenig@pengutronix.de>
 <f546b5f0-1da6-2c16-647a-33bb8692b753@ti.com>
 <20160727070302.GG5368@pengutronix.de>
 <076e6aa6-91f3-8707-1d8b-504c4962f7cd@ti.com>
 <20160727143804.GC5629@pengutronix.de>
 <fc2a3300-4f6b-aff7-995d-77b37bdaab65@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Mugunthan V N <mugunthanvnm@ti.com>, linux-omap@vger.kernel.org,
	kernel@pengutronix.de, netdev@vger.kernel.org
To: Grygorii Strashko <grygorii.strashko@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:58997 "EHLO
	metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757262AbcG1MMe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jul 2016 08:12:34 -0400
Content-Disposition: inline
In-Reply-To: <fc2a3300-4f6b-aff7-995d-77b37bdaab65@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Grygorii,

On Thu, Jul 28, 2016 at 12:34:19PM +0300, Grygorii Strashko wrote:
> Thanks. I've just wanted to have clear understanding of the [possible=
] issue.
> And I'd be appreciated if you could share and measurement results if =
you have.

I didn't measure anything (yet), just considered these patches
low-hanging fruits. But when looking again there, I will provide some
numbers.

Best regards
Uwe

--=20
Pengutronix e.K.                           | Uwe Kleine-K=F6nig        =
    |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |
