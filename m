From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 00/10] net: dsa: Global 2 cosmetics
Date: Tue, 20 Jun 2017 13:25:52 -0400 (EDT)
Message-ID: <20170620.132552.301264868003562461.davem@davemloft.net>
References: <20170619145545.26697-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com, f.fainelli@gmail.com, andrew@lunn.ch
To: vivien.didelot@savoirfairelinux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170619145545.26697-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Mon, 19 Jun 2017 10:55:35 -0400

> Similarly to what has been done for the Port and Global 1 registers,
> this patch series prefixes and documents the macros of Global 2.
> 
> It brings no functional changes except for 1/10 which fixes the IRL init
> for 88E6390 family.
> 
> Changes in v2: make *_g2_irl_init_all static inline without
> NET_DSA_MV88E6XXX_GLOBAL2 and compile test with and without the symbol.

Series applied, thanks Vivien.
