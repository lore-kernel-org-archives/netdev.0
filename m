From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 3/5] net: phy: split out 10G genphy support
Date: Thu, 1 Jun 2017 14:29:04 +0200
Message-ID: <20170601122904.GC9282@lunn.ch>
References: <20170601102327.GF27796@n2100.armlinux.org.uk>
 <E1dGNJR-00043n-ON@rmk-PC.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
To: Russell King <rmk+kernel@armlinux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:60983 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751054AbdFAM3G (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 1 Jun 2017 08:29:06 -0400
Content-Disposition: inline
In-Reply-To: <E1dGNJR-00043n-ON@rmk-PC.armlinux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 01, 2017 at 11:26:41AM +0100, Russell King wrote:
> Move the old 10G genphy support to sit beside the new clause 45 library
> functions, so all the 10G phy code is together.
> 
> Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
