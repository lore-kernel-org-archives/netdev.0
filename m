From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: phy: fix kernel-doc warnings
Date: Mon, 5 Jun 2017 14:06:56 +0200
Message-ID: <20170605120656.GD28734@lunn.ch>
References: <3d006e19-8c96-a752-fbcb-bf8fc7ccb386@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Randy Dunlap <rdunlap@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:36509 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751747AbdFEMHA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 5 Jun 2017 08:07:00 -0400
Content-Disposition: inline
In-Reply-To: <3d006e19-8c96-a752-fbcb-bf8fc7ccb386@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 04, 2017 at 07:46:53PM -0700, Randy Dunlap wrote:
> From: Randy Dunlap <rdunlap@infradead.org>
> 
> Fix kernel-doc warnings (typo) in drivers/net/phy/phy.c:
> 
> ..//drivers/net/phy/phy.c:259: warning: No description found for parameter 'features'
> ..//drivers/net/phy/phy.c:259: warning: Excess function parameter 'feature' description in 'phy_lookup_setting'
> 
> Signed-off-by: Randy Dunlap <rdunlap@infradead.org>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
