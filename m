From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 3/4] net: phy: Add read driver for Microsemi PHYs.
Date: Wed, 24 Aug 2016 15:13:47 +0200
Message-ID: <20160824131347.GE13406@lunn.ch>
References: <646450A91FAED74E85C6E9C4D6E936A1453366A5@avsrvexchmbx1.microsemi.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "f.fainelli@gmail.com" <f.fainelli@gmail.com>,
        Allan Nielsen <Allan.Nielsen@microsemi.com>
To: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:43297 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754283AbcHXNNy (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 24 Aug 2016 09:13:54 -0400
Content-Disposition: inline
In-Reply-To: <646450A91FAED74E85C6E9C4D6E936A1453366A5@avsrvexchmbx1.microsemi.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 24, 2016 at 12:27:07PM +0000, Raju Lakkaraju wrote:
> From: Nagaraju Lakkaraju <Raju.Lakkaraju@microsemi.com>
> 
> PHY Read support will be added for VSC 85xx Microsemi PHYs.

Why do i need this, when we have SIOCGMIIREG? 

    Andrew
