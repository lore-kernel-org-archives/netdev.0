From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sh_eth: fix typo in RX descriptor bit name
Date: Mon, 02 Nov 2015 23:01:25 -0500 (EST)
Message-ID: <20151102.230125.542085160495385546.davem@davemloft.net>
References: <2943003.kyUQtQdRCT@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org
To: sergei.shtylyov@cogentembedded.com
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <2943003.kyUQtQdRCT@wasted.cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Tue, 03 Nov 2015 01:28:07 +0300

> The correct name of the RX descriptor 0 bit 30 is RDLE (receive descriptor
> list end),  not  RDEL.
> 
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
> 
> ---
> The patch is against the Dave Miller's 'net-next.git' repo.

Applied.
