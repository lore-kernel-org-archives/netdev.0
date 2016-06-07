From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v3 2/6] net: dsa: Initialize
 ds->enabled_port_mask and ds->phys_mii_mask
Date: Tue, 7 Jun 2016 23:32:13 +0200
Message-ID: <20160607213213.GD28994@lunn.ch>
References: <1465333616-6351-1-git-send-email-f.fainelli@gmail.com>
 <1465333616-6351-3-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	vivien.didelot@savoirfairelinux.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:38293 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1160995AbcFGVcR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Jun 2016 17:32:17 -0400
Content-Disposition: inline
In-Reply-To: <1465333616-6351-3-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 07, 2016 at 02:06:52PM -0700, Florian Fainelli wrote:
> Some drivers rely on these two bitmasks to contain the correct values
> for them to successfully probe and initialize at drv->setup() time,
> calculate correct values to put in both masks as early as possible in
> dsa_get_ports_dn().
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
