From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/m68k: Hydra Ethernet - print whole resource
 instead of start address
Date: Mon, 30 Aug 2010 13:51:36 -0700 (PDT)
Message-ID: <20100830.135136.98876124.davem@davemloft.net>
References: <alpine.DEB.2.00.1008300942560.30729@ayla.of.borg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-m68k@lists.linux-m68k.org,
	linux-kernel@vger.kernel.org
To: geert@linux-m68k.org
Return-path: <linux-m68k-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.00.1008300942560.30729@ayla.of.borg>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Mon, 30 Aug 2010 09:43:46 +0200 (CEST)

> resource_size_t changed from `unsigned long' to `phys_addr_t`, which is either
> `u32' or `u64'.
> Print the whole resource to remove the cast and to make it future-proof.
> 
> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>

Applied to net-next-2.6, thanks!
