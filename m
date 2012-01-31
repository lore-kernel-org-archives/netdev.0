From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] drivers/net: Remove alloc_etherdev error
 messages
Date: Tue, 31 Jan 2012 16:41:14 -0500 (EST)
Message-ID: <20120131.164114.2078156017513708279.davem@davemloft.net>
References: <1327877783.2652.10.camel@joe2Laptop>
	<1327880872.2652.12.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1327880872.2652.12.camel@joe2Laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Sun, 29 Jan 2012 15:47:52 -0800

> alloc_etherdev has a generic OOM/unable to alloc message.
> Remove the duplicative messages after alloc_etherdev calls.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied.
