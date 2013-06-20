From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/2] sh_eth: define/use EESR_RX_CHECK macro
Date: Wed, 19 Jun 2013 17:03:28 -0700 (PDT)
Message-ID: <20130619.170328.1736421710188084110.davem@davemloft.net>
References: <201306192329.24022.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nobuhiro.iwamatsu.yj@renesas.com,
	linux-sh@vger.kernel.org
To: sergei.shtylyov@cogentembedded.com
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <201306192329.24022.sergei.shtylyov@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Wed, 19 Jun 2013 23:29:23 +0400

> sh_eth_interrupt() uses the same Rx interrupt mask twice to check the interrupt
> status register -- #define EESR_RX_CHECK  and use it instead. 
> 
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Applied.
