From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/macb: GEM DMA configuration register update
Date: Fri, 23 Nov 2012 14:30:33 -0500 (EST)
Message-ID: <20121123.143033.141910826801165909.davem@davemloft.net>
References: <1353678541-26839-1-git-send-email-nicolas.ferre@atmel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org, manabian@gmail.com,
	plagnioj@jcrosoft.com
To: nicolas.ferre@atmel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1353678541-26839-1-git-send-email-nicolas.ferre@atmel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nicolas Ferre <nicolas.ferre@atmel.com>
Date: Fri, 23 Nov 2012 14:49:01 +0100

> Add information to the DMA Configuration Register to
> maximize system performance:
> - rx/tx packet buffer full memory size
> - allow possibility to use INCR16 if supported
> 
> Signed-off-by: Nicolas Ferre <nicolas.ferre@atmel.com>

Applied to net-next.
