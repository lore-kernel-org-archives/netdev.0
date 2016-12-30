From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: dsa: Implement ndo_get_phys_port_id
Date: Thu, 29 Dec 2016 22:17:19 -0500 (EST)
Message-ID: <20161229.221719.277090119224452126.davem@davemloft.net>
References: <20161229222056.12490-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, linux-kernel@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161229222056.12490-1-f.fainelli@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Thu, 29 Dec 2016 14:20:56 -0800

> Implement ndo_get_phys_port_id() by returning the physical port number
> of the switch this per-port DSA created network interface corresponds
> to.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied, thanks.
