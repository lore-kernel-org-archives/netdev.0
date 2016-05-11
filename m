From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next] phy: micrel: Use MICREL_PHY_ID_MASK definition
Date: Wed, 11 May 2016 23:29:00 +0200
Message-ID: <20160511212900.GB21243@lunn.ch>
References: <1462996925-7153-1-git-send-email-festevam@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, f.fainelli@gmail.com, netdev@vger.kernel.org,
	Fabio Estevam <fabio.estevam@nxp.com>
To: Fabio Estevam <festevam@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:36354 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751617AbcEKV3F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 May 2016 17:29:05 -0400
Content-Disposition: inline
In-Reply-To: <1462996925-7153-1-git-send-email-festevam@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 11, 2016 at 05:02:05PM -0300, Fabio Estevam wrote:
> From: Fabio Estevam <fabio.estevam@nxp.com>
> 
> Replace the hardcoded mask 0x00fffff0 with MICREL_PHY_ID_MASK for
> better readability.
> 
> Suggested-by: Andrew Lunn <andrew@lunn.ch>
> Signed-off-by: Fabio Estevam <fabio.estevam@nxp.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

Thanks
	Andrew
