From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v6 4/5] netdev: ethernet dev_alloc_skb to
 netdev_alloc_skb
Date: Wed, 08 Feb 2012 18:50:50 -0500 (EST)
Message-ID: <20120208.185050.869030284425092445.davem@davemloft.net>
References: <d8ad7b1e88df72e284cbc8b8fba1745530923375.1328445742.git.netdev@pradeepdalvi.com>
	<16d58f0e1810fcefbe4e2028a5690caad37d2c34.1328562210.git.netdev@pradeepdalvi.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@pradeepdalvi.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <16d58f0e1810fcefbe4e2028a5690caad37d2c34.1328562210.git.netdev@pradeepdalvi.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pradeep A Dalvi <netdev@pradeepdalvi.com>
Date: Tue,  7 Feb 2012 02:46:13 +0530

> Replaced deprecating dev_alloc_skb with netdev_alloc_skb in drivers/net/ethernet
>   - Removed extra skb->dev = dev after netdev_alloc_skb
> 
> Signed-off-by: Pradeep A Dalvi <netdev@pradeepdalvi.com>

Applied.
