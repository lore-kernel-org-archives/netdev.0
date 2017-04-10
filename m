From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 6/6] net: mvmdio: allow up to three clocks to be
 specified for orion-mdio
Date: Mon, 10 Apr 2017 21:31:28 +0200
Message-ID: <20170410193128.GE32277@lunn.ch>
References: <20170410152728.GT17774@n2100.armlinux.org.uk>
 <E1cxbF1-0006gf-54@rmk-PC.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Marcin Wojtas <mw@semihalf.com>,
        Stefan Chulski <stefanc@marvell.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
        netdev@vger.kernel.org
To: Russell King <rmk+kernel@armlinux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:54067 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752086AbdDJTbd (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 10 Apr 2017 15:31:33 -0400
Content-Disposition: inline
In-Reply-To: <E1cxbF1-0006gf-54@rmk-PC.armlinux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 10, 2017 at 04:28:31PM +0100, Russell King wrote:
> Allow up to three clocks to be specified and enabled for the orion-mdio
> interface, which are required for this interface to be accessible on
> Armada 8k platforms.
> 
> Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
