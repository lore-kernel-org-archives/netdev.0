From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: mv88e6xxx: Fix ingress rate removal for mv6131 chips
Date: Tue, 23 Aug 2016 01:09:36 +0200
Message-ID: <20160822230936.GF31727@lunn.ch>
References: <1471902428-24250-1-git-send-email-jm@lentin.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
To: Jamie Lentin <jm@lentin.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:41041 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756313AbcHVXJk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 22 Aug 2016 19:09:40 -0400
Content-Disposition: inline
In-Reply-To: <1471902428-24250-1-git-send-email-jm@lentin.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 22, 2016 at 10:47:08PM +0100, Jamie Lentin wrote:
> The PORT_RATE_CONTROL register works differently on 88e6095/6095f/6131
> in comparison to 6123/61/65, and 0x0 disables. The distinction was lost
> Linux 4.1 --> 4.2
> 
> Signed-off-by: Jamie Lentin <jm@lentin.co.uk>

Hi Jamie

Thanks for the patch.

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
