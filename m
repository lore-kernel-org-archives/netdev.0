From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v2 2/5] ethtool: Implements
 ETHTOOL_PHY_GTUNABLE/ETHTOOL_PHY_STUNABLE
Date: Mon, 14 Nov 2016 14:40:11 +0100
Message-ID: <20161114134011.GH26710@lunn.ch>
References: <1479115760-1182-1-git-send-email-allan.nielsen@microsemi.com>
 <1479115760-1182-3-git-send-email-allan.nielsen@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, raju.lakkaraju@microsemi.com
To: "Allan W. Nielsen" <allan.nielsen@microsemi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:37832 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752210AbcKNNkN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 14 Nov 2016 08:40:13 -0500
Content-Disposition: inline
In-Reply-To: <1479115760-1182-3-git-send-email-allan.nielsen@microsemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 14, 2016 at 10:29:17AM +0100, Allan W. Nielsen wrote:
> From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
> 
> Adding get_tunable/set_tunable function pointer to the phy_driver
> structure, and uses these function pointers to implement the
> ETHTOOL_PHY_GTUNABLE/ETHTOOL_PHY_STUNABLE ioctls.
> 
> Signed-off-by: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
