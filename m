From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next] mdio: Demote print from info to debug in
 mdio_device_register
Date: Sat, 7 Jan 2017 19:17:52 +0100
Message-ID: <20170107181752.GA29828@lunn.ch>
References: <20170107062759.32015-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:48171 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932653AbdAGSRz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 7 Jan 2017 13:17:55 -0500
Content-Disposition: inline
In-Reply-To: <20170107062759.32015-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 06, 2017 at 10:27:59PM -0800, Florian Fainelli wrote:
> While it is useful to know which MDIO device is being registered, demote
> the dev_info() to a dev_dbg().
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
