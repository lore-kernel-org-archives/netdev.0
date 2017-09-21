From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: dsa: use dedicated CPU port
Date: Thu, 21 Sep 2017 15:16:15 -0700 (PDT)
Message-ID: <20170921.151615.2026069601384753715.davem@davemloft.net>
References: <20170920162805.29503-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com, f.fainelli@gmail.com, andrew@lunn.ch
To: vivien.didelot@savoirfairelinux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170920162805.29503-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Wed, 20 Sep 2017 12:28:05 -0400

> Each port in DSA has its own dedicated CPU port currently available in
> its parent switch's ds->ports[port].cpu_dp. Use it instead of getting
> the unique tree CPU port, which will be deprecated soon.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Applied.
