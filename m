From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v6 5/5] netdev: ethernet dev_alloc_skb to
 netdev_alloc_skb
Date: Wed, 08 Feb 2012 18:50:55 -0500 (EST)
Message-ID: <20120208.185055.2055806444634975498.davem@davemloft.net>
References: <6fbe769a05ae20f89f6112bd2a7ccbb085ed874d.1328445742.git.netdev@pradeepdalvi.com>
	<ce53bc956b35497724bbbb76ab07bfc4c5b78291.1328562210.git.netdev@pradeepdalvi.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@pradeepdalvi.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <ce53bc956b35497724bbbb76ab07bfc4c5b78291.1328562210.git.netdev@pradeepdalvi.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pradeep A Dalvi <netdev@pradeepdalvi.com>
Date: Tue,  7 Feb 2012 02:46:48 +0530

> Replaced deprecating dev_alloc_skb with netdev_alloc_skb in drivers/net/ethernet
>   - Removed extra skb->dev = dev after netdev_alloc_skb
> 
> Signed-off-by: Pradeep A Dalvi <netdev@pradeepdalvi.com>

Applied.
