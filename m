From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 03/12] net/ethernet: NET_CALXEDA_XGMAC should depend on
 HAS_DMA
Date: Sat, 11 May 2013 16:28:43 -0700 (PDT)
Message-ID: <20130511.162843.702635467794467039.davem@davemloft.net>
References: <1368133494-22198-1-git-send-email-geert@linux-m68k.org>
	<1368133494-22198-3-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, rob.herring@calxeda.com,
	netdev@vger.kernel.org
To: geert@linux-m68k.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1368133494-22198-3-git-send-email-geert@linux-m68k.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Thu,  9 May 2013 23:04:45 +0200

> If NO_DMA=y:
> 
> drivers/built-in.o: In function `xgmac_xmit':
> drivers/net/ethernet/calxeda/xgmac.c:1102: undefined reference to `dma_mapping_error'
> 
> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>

Applied.
