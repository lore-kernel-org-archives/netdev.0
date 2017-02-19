From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] of_mdio: Add "broadcom,bcm5241" to the whitelist.
Date: Sun, 19 Feb 2017 18:20:14 -0500 (EST)
Message-ID: <20170219.182014.1876208661231418976.davem@davemloft.net>
References: <20170217200412.11680-1-david.daney@cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org, robh+dt@kernel.org,
        frowand.list@gmail.com, linux-kernel@vger.kernel.org
To: david.daney@cavium.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170217200412.11680-1-david.daney@cavium.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Daney <david.daney@cavium.com>
Date: Fri, 17 Feb 2017 12:04:12 -0800

> Some Cavium dev boards have firmware which doesn't supply a proper
> ethernet-phy-ieee802.3-c22" compatible property.  Restore these boards
> to working order by whitelisting this compatible value.
> 
> Signed-off-by: David Daney <david.daney@cavium.com>

Applied.
