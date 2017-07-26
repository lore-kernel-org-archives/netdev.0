From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next] net: phy: Remove stale comments referencing
 timer
Date: Wed, 26 Jul 2017 21:19:46 +0200
Message-ID: <20170726191946.GV12049@lunn.ch>
References: <20170726190538.27674-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, slash.tmp@free.fr
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:41382 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751011AbdGZTTu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 26 Jul 2017 15:19:50 -0400
Content-Disposition: inline
In-Reply-To: <20170726190538.27674-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 26, 2017 at 12:05:38PM -0700, Florian Fainelli wrote:
> Since commit a390d1f379cf ("phylib: convert state_queue work to
> delayed_work"), the PHYLIB state machine was converted to use delayed
> workqueues, yet some functions were still referencing the PHY library
> timer in their comments, fix that and remove the now unused
> linux/timer.h include.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
