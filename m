From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v3 3/6] net: dsa: Provide a slave MII bus if
 needed
Date: Tue, 7 Jun 2016 23:40:13 +0200
Message-ID: <20160607214013.GE28994@lunn.ch>
References: <1465333616-6351-1-git-send-email-f.fainelli@gmail.com>
 <1465333616-6351-4-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	vivien.didelot@savoirfairelinux.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:38298 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161185AbcFGVkP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Jun 2016 17:40:15 -0400
Content-Disposition: inline
In-Reply-To: <1465333616-6351-4-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 07, 2016 at 02:06:53PM -0700, Florian Fainelli wrote:
> Mimic what net/dsa/dsa.c does and provide a slave MII bus by default
> which will be created if the driver implements a phy_read method.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

	Andrew
