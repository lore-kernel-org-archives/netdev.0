From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: macb: Only call GPIO functions if there is a
 valid GPIO
Date: Mon, 28 Mar 2016 11:40:13 -0400 (EDT)
Message-ID: <20160328.114013.2144667113443554424.davem@davemloft.net>
References: <1459169262-3941-1-git-send-email-ckeepax@opensource.wolfsonmicro.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.ferre@atmel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, patches@opensource.wolfsonmicro.com
To: ckeepax@opensource.wolfsonmicro.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1459169262-3941-1-git-send-email-ckeepax@opensource.wolfsonmicro.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Charles Keepax <ckeepax@opensource.wolfsonmicro.com>
Date: Mon, 28 Mar 2016 13:47:42 +0100

> GPIOlib will print warning messages if we call GPIO functions without a
> valid GPIO. Change the code to avoid doing so.
> 
> Signed-off-by: Charles Keepax <ckeepax@opensource.wolfsonmicro.com>

Applied.
