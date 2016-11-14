From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v2 1/5] ethtool: (uapi) Add ETHTOOL_PHY_GTUNABLE
 and ETHTOOL_PHY_STUNABLE
Date: Mon, 14 Nov 2016 14:36:56 +0100
Message-ID: <20161114133656.GG26710@lunn.ch>
References: <1479115760-1182-1-git-send-email-allan.nielsen@microsemi.com>
 <1479115760-1182-2-git-send-email-allan.nielsen@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, raju.lakkaraju@microsemi.com
To: "Allan W. Nielsen" <allan.nielsen@microsemi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:37822 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752517AbcKNNg5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 14 Nov 2016 08:36:57 -0500
Content-Disposition: inline
In-Reply-To: <1479115760-1182-2-git-send-email-allan.nielsen@microsemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 14, 2016 at 10:29:16AM +0100, Allan W. Nielsen wrote:
> From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
> 
> Defines a generic API to get/set phy tunables. The API is using the
> existing ethtool_tunable/tunable_type_id types which is already being used
> for mac level tunables.
> 
> Signed-off-by: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
