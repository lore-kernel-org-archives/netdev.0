From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
        <u.kleine-koenig@pengutronix.de>
Subject: Re: [PATCH net-next] net: ethernet: ax88796: support generating a
 random mac address
Date: Thu, 25 May 2017 22:57:41 +0200
Message-ID: <20170525205741.yoyiszdgchqcnqp2@pengutronix.de>
References: <20170525205511.22048-1-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, kernel@pengutronix.de
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:41327 "EHLO
        metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751861AbdEYU5n (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 May 2017 16:57:43 -0400
Content-Disposition: inline
In-Reply-To: <20170525205511.22048-1-u.kleine-koenig@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

On Thu, May 25, 2017 at 10:55:11PM +0200, Uwe Kleine-König wrote:
> Instead of falling back to 00:00:00:00:00:00 generate a random address
> if none is provided via platform data or from the the device's register

s/the the/the/

should I resend for this, or can you fixup at commit time (assuming this
patch is ok).

Best regards
Uwe

-- 
Pengutronix e.K.                           | Uwe Kleine-König            |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
