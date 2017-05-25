From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next] net: ethernet: ax88796: support generating a
 random mac address
Date: Thu, 25 May 2017 23:25:18 +0200
Message-ID: <20170525212518.GA26939@lunn.ch>
References: <20170525205511.22048-1-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        kernel@pengutronix.de
To: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
        <u.kleine-koenig@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:45026 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S970258AbdEYVZX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 25 May 2017 17:25:23 -0400
Content-Disposition: inline
In-Reply-To: <20170525205511.22048-1-u.kleine-koenig@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 25, 2017 at 10:55:11PM +0200, Uwe Kleine-König wrote:
> Instead of falling back to 00:00:00:00:00:00 generate a random address
> if none is provided via platform data or from the the device's register
> space.
> 
> Signed-off-by: Uwe Kleine-König <u.kleine-koenig@pengutronix.de>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
