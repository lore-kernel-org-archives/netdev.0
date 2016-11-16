From: Tobias Klauser <tklauser@distanz.ch>
Subject: Re: [PATCH net-next 2/5] net: ethoc: Implement ethtool::nway_reset
Date: Wed, 16 Nov 2016 08:38:41 +0100
Message-ID: <20161116073841.GC3373@distanz.ch>
References: <20161115191949.15361-1-f.fainelli@gmail.com>
 <20161115191949.15361-3-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, andrew@lunn.ch,
        tremyfr@gmail.com, Colin Ian King <colin.king@canonical.com>,
        open list <linux-kernel@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161115191949.15361-3-f.fainelli@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2016-11-15 at 20:19:46 +0100, Florian Fainelli <f.fainelli@gmail.com> wrote:
> Implement ethtool::nway_reset using phy_ethtool_nway_reset. We are
> already using dev->phydev all over the place so this comes for free.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Reviewed-by: Tobias Klauser <tklauser@distanz.ch>
