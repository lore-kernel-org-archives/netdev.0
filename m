From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 3/8] net: dsa: mv88e6xxx: use already declared
 variables
Date: Thu, 9 Jun 2016 04:31:06 +0200
Message-ID: <20160609023106.GI2227@lunn.ch>
References: <20160609004456.5441-1-vivien.didelot@savoirfairelinux.com>
 <20160609004456.5441-4-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:39451 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161396AbcFICbH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jun 2016 22:31:07 -0400
Content-Disposition: inline
In-Reply-To: <20160609004456.5441-4-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 08, 2016 at 08:44:51PM -0400, Vivien Didelot wrote:
> In the MDIO probing function, dev is already assigned to &mdiodev->dev
> and np is already assigned to mdiodev->dev.of_node, so use them.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
