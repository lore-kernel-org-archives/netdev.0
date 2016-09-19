From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v3 net-next] net: phy: Add MAC-IF driver for Microsemi
 PHYs.
Date: Mon, 19 Sep 2016 17:46:33 +0200
Message-ID: <20160919154633.GF8651@lunn.ch>
References: <1474279434-14583-1-git-send-email-Raju.Lakkaraju@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com,
        Allan.Nielsen@microsemi.com
To: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:52239 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751092AbcISPqg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 19 Sep 2016 11:46:36 -0400
Content-Disposition: inline
In-Reply-To: <1474279434-14583-1-git-send-email-Raju.Lakkaraju@microsemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 19, 2016 at 03:33:54PM +0530, Raju Lakkaraju wrote:
> From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
> 
> All the review comments updated and resending for review.

Hi Raju

Please put comments like the above below the --- line. They then don't
get placed into the commit log in git.

Also, please include a brief summary of what changed for each version
of a patch. That makes it easier for the reviewer. Again, this should
be below the ---.

> 
> This is MAC interface feature.
> Microsemi PHY can support RGMII, RMII or GMII/MII interface between MAC and PHY.
> MAC-IF function program the right value based on Device tree configuration.
> 
> Tested on Beaglebone Black with VSC 8531 PHY.
> 
> Signed-off-by: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
