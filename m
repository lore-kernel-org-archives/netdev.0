From: David Miller <davem@davemloft.net>
Subject: Re: mmotm 2014-01-02-14-35 uploaded (brocade/bna)
Date: Mon, 06 Jan 2014 17:24:27 -0500 (EST)
Message-ID: <20140106.172427.1901836894729408800.davem@davemloft.net>
References: <20140102223649.D8FB931C206@corp2gmr1-1.hot.corp.google.com>
	<52C700B9.8040504@infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, rmody@brocade.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-next@vger.kernel.org
To: rdunlap@infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <52C700B9.8040504@infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <rdunlap@infradead.org>
Date: Fri, 03 Jan 2014 10:26:01 -0800

> as reported for linux-next of Dec.20, 2013
> when CONFIG_NEED_DMA_MAP_STATE is not enabled:
> 
> drivers/net/ethernet/brocade/bna/bnad.c: In function 'bnad_start_xmit':
> drivers/net/ethernet/brocade/bna/bnad.c:3074:26: error: 'struct bnad_tx_vector' has no member named 'dma_len'

Sorry for taking so long, I plan to look into this tonight Randy.
