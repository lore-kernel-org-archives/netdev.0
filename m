From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 2/3] net-next: mediatek: add fixed-phy support
Date: Thu, 5 May 2016 14:02:53 +0200
Message-ID: <20160505120253.GD7972@lunn.ch>
References: <1462439856-51788-1-git-send-email-john@phrozen.org>
 <1462439856-51788-3-git-send-email-john@phrozen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, nbd@nbd.name,
	netdev@vger.kernel.org, linux-mediatek@lists.infradead.org,
	linux-kernel@vger.kernel.org
To: John Crispin <john@phrozen.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:57535 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750905AbcEEMDF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 May 2016 08:03:05 -0400
Content-Disposition: inline
In-Reply-To: <1462439856-51788-3-git-send-email-john@phrozen.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 05, 2016 at 11:17:35AM +0200, John Crispin wrote:
> The MT7623 SoC has a builtin gigabit switch. If we want to use it, GMAC1
> needs to be configured using a fixed link speed and flow control settings.
> The easiest way to do this is to used the fixed-phy driver, allowing us to
> reuse the existing mdio polling code to setup the MAC.
> 
> Signed-off-by: John Crispin <john@phrozen.org>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

Looks good.

      Andrew
