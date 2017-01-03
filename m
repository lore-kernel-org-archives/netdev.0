From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/2] net: mdio: add mdio45_ethtool_ksettings_get
Date: Mon, 02 Jan 2017 19:30:54 -0500 (EST)
Message-ID: <20170102.193054.1244119181880280691.davem@davemloft.net>
References: <1483293766-4581-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers@solarflare.com, ecree@solarflare.com,
        bkenward@solarflare.com, andrew@lunn.ch, f.fainelli@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1483293766-4581-1-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Philippe Reynes <tremyfr@gmail.com>
Date: Sun,  1 Jan 2017 19:02:45 +0100

> There is a function in mdio for the old ethtool api gset.
> We add a new function mdio45_ethtool_ksettings_get for the
> new ethtool api glinksettings.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
> ---
> Changelog:
> v2:
> - simplify the code of ef4_ethtool_get_link_ksettings
>   (feedback from Bert Kenward)

Applied.
