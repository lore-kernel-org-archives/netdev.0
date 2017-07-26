From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH RFC 04/13] net: phy: add 1000Base-X to phy settings table
Date: Wed, 26 Jul 2017 23:52:55 +0200
Message-ID: <20170726215255.GC7966@lunn.ch>
References: <20170725140138.GK31807@n2100.armlinux.org.uk>
 <E1da0QG-0007LL-Vj@rmk-PC.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
To: Russell King <rmk+kernel@armlinux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:41534 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750952AbdGZVw4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 26 Jul 2017 17:52:56 -0400
Content-Disposition: inline
In-Reply-To: <E1da0QG-0007LL-Vj@rmk-PC.armlinux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 25, 2017 at 03:02:52PM +0100, Russell King wrote:
> Add the missing 1000Base-X entry to the phy settings table.  This was
> not included because the original code could not cope with more than
> 32 bits of link mode mask.
> 
> Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>

Hi Russell

Looks like there are another 15 to add to the table. But that can wait
for another time when somebody needs them.

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
