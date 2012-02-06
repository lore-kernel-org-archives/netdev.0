From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5 3/5] netdev: ethernet dev_alloc_skb to
 netdev_alloc_skb
Date: Mon, 06 Feb 2012 11:52:37 -0500 (EST)
Message-ID: <20120206.115237.1441678844772472135.davem@davemloft.net>
References: <cf736034e7bd407297e2ea9fbf247fb410eb7b39.1328445742.git.netdev@pradeepdalvi.com>
	<ef62da964e8660dfdf2a25cd643631bb15914ecf.1328445742.git.netdev@pradeepdalvi.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@pradeepdalvi.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <ef62da964e8660dfdf2a25cd643631bb15914ecf.1328445742.git.netdev@pradeepdalvi.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Pradeep A. Dalvi" <netdev@pradeepdalvi.com>
Date: Sun,  5 Feb 2012 18:20:38 +0530

> From: Pradeep A Dalvi <netdev@pradeepdalvi.com>
> 
> Replaced deprecating dev_alloc_skb with netdev_alloc_skb in drivers/net/ethernet
>   - Removed extra skb->dev = dev after netdev_alloc_skb
> 
> Signed-off-by: Pradeep A Dalvi <netdev@pradeepdalvi.com>

Applied.
