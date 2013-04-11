From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: mv643xx_eth: Add GRO support
Date: Thu, 11 Apr 2013 16:22:45 -0400 (EDT)
Message-ID: <20130411.162245.954727103094202894.davem@davemloft.net>
References: <1365684023-9967-1-git-send-email-sebastian.hesselbarth@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: smoch@web.de, buytenh@wantstofly.org, andrew@lunn.ch,
	jason@lakedaemon.net, florian@openwrt.org,
	benh@kernel.crashing.org, paulus@samba.org, dale@farnsworth.org,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org
To: sebastian.hesselbarth@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1365684023-9967-1-git-send-email-sebastian.hesselbarth@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Date: Thu, 11 Apr 2013 14:40:23 +0200

> This patch adds GRO support to mv643xx_eth by making it invoke
> napi_gro_receive instead of netif_receive_skb.
> 
> Signed-off-by: Soeren Moch <smoch@web.de>
> Signed-off-by: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>

Applied.
