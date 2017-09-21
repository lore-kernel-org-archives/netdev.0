From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: dsa: better scoping of slave functions
Date: Thu, 21 Sep 2017 15:24:17 -0700 (PDT)
Message-ID: <20170921.152417.22307694038141655.davem@davemloft.net>
References: <20170920233157.6832-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com, f.fainelli@gmail.com, andrew@lunn.ch
To: vivien.didelot@savoirfairelinux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170920233157.6832-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Wed, 20 Sep 2017 19:31:57 -0400

> A few DSA slave functions take a dsa_slave_priv pointer as first
> argument, whereas the scope of the slave.c functions is the slave
> net_device structure. Fix this and rename dsa_netpoll_send_skb to
> dsa_slave_netpoll_send_skb.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Applied.
