From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH RFC 02/13] net: phy: split out PHY speed and duplex
 string generation
Date: Wed, 26 Jul 2017 23:48:19 +0200
Message-ID: <20170726214819.GB7966@lunn.ch>
References: <20170725140138.GK31807@n2100.armlinux.org.uk>
 <E1da0Q6-0007Kv-Mc@rmk-PC.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
To: Russell King <rmk+kernel@armlinux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:41528 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751175AbdGZVsU (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 26 Jul 2017 17:48:20 -0400
Content-Disposition: inline
In-Reply-To: <E1da0Q6-0007Kv-Mc@rmk-PC.armlinux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 25, 2017 at 03:02:42PM +0100, Russell King wrote:
> Other code would like to make use of this, so make the speed and duplex
> string generation visible, and place it in a separate file.
> 
> Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
