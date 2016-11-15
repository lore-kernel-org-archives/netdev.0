From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v3 3/5] ethtool: (uapi) Add
 ETHTOOL_PHY_DOWNSHIFT to PHY tunables
Date: Tue, 15 Nov 2016 14:45:32 +0100
Message-ID: <20161115134532.GB20621@lunn.ch>
References: <1479205204-27768-1-git-send-email-allan.nielsen@microsemi.com>
 <1479205204-27768-4-git-send-email-allan.nielsen@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, raju.lakkaraju@microsemi.com
To: "Allan W. Nielsen" <allan.nielsen@microsemi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:40315 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751359AbcKONpf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 15 Nov 2016 08:45:35 -0500
Content-Disposition: inline
In-Reply-To: <1479205204-27768-4-git-send-email-allan.nielsen@microsemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 15, 2016 at 11:20:02AM +0100, Allan W. Nielsen wrote:
> From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
> 
> For operation in cabling environments that are incompatible with
> 1000BASE-T, PHY device may provide an automatic link speed downshift
> operation. When enabled, the device automatically changes its 1000BASE-T
> auto-negotiation to the next slower speed after a configured number of
> failed attempts at 1000BASE-T.  This feature is useful in setting up in
> networks using older cable installations that include only pairs A and B,
> and not pairs C and D.
> 
> Signed-off-by: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
> Signed-off-by: Allan W. Nielsen <allan.nielsen@microsemi.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
