From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/3] net: dsa: mv88e6xxx: remove unused
 phy_mutex
Date: Wed, 20 Jul 2016 14:57:25 -0700 (PDT)
Message-ID: <20160720.145725.2139832992930753072.davem@davemloft.net>
References: <20160720160547.30133-1-vivien.didelot@savoirfairelinux.com>
	<20160720160547.30133-2-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com, andrew@lunn.ch, f.fainelli@gmail.com
To: vivien.didelot@savoirfairelinux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160720160547.30133-2-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Wed, 20 Jul 2016 12:05:45 -0400

> Only reg_lock is necessary now and phy_mutex is dead. Remove it.
> ---
>  drivers/net/dsa/mv88e6xxx/mv88e6xxx.h | 6 ------
>  1 file changed, 6 deletions(-)

Missing a proper Signoff.
