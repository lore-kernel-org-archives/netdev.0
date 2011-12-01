From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers/net/ethernet/tile: use skb_frag_page() API
Date: Thu, 01 Dec 2011 13:31:14 -0500 (EST)
Message-ID: <20111201.133114.1983782132846748196.davem@davemloft.net>
References: <201112011815.pB1IFD2t004910@farm-0002.internal.tilera.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: cmetcalf@tilera.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201112011815.pB1IFD2t004910@farm-0002.internal.tilera.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chris Metcalf <cmetcalf@tilera.com>
Date: Thu, 1 Dec 2011 12:56:03 -0500

> This replaces raw access to the "page" field of the skb_frag_t.
> 
> Signed-off-by: Chris Metcalf <cmetcalf@tilera.com>

Please merge these changes via your Tile tree, you can add my:

Acked-by: David S. Miller <davem@davemloft.net>

Thanks.
