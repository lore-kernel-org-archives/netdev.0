From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 1/2] net: phy: Fix typo for MDIO module
 boilerplate comment
Date: Mon, 23 Jan 2017 16:00:04 +0100
Message-ID: <20170123150004.GB10895@lunn.ch>
References: <20170123051733.10316-1-f.fainelli@gmail.com>
 <20170123051733.10316-2-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        vivien.didelot@savoirfairelinux.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:41656 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751083AbdAWPAI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 23 Jan 2017 10:00:08 -0500
Content-Disposition: inline
In-Reply-To: <20170123051733.10316-2-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 22, 2017 at 09:17:32PM -0800, Florian Fainelli wrote:
> The module boilerplate macro is named mdio_module_driver and not
> module_mdio_driver, fix that.
> 
> Fixes: a9049e0c513c ("mdio: Add support for mdio drivers.")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
