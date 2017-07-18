From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/12] net: dsa: mv88e6xxx: cleanup
 capabilities
Date: Tue, 18 Jul 2017 11:11:14 -0700 (PDT)
Message-ID: <20170718.111114.2176233751633219368.davem@davemloft.net>
References: <20170717170346.19555-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com, f.fainelli@gmail.com, andrew@lunn.ch
To: vivien.didelot@savoirfairelinux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170717170346.19555-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Mon, 17 Jul 2017 13:03:34 -0400

> This patch series removes the remaining capabilities as well as the
> flags bitmap in the info structures. Most of them are turned into ops,
> or new info members.
> 
> There is no mv88e6xxx_cap enum or bitmap flags anymore, only
> mv88e6xxx_info and mv88e6xxx_ops structures.
> 
> While reviewing and documenting the related G2 registers, fix a few
> inconsistencies: 88E6185 has no interrupt in G2 and 88E6390 has a POT.
> 
> Except these two adjustments, there is no functional changes.

Series applied, thanks Vivien.
