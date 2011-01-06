From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: r6040: Return proper error for r6040_init_one
Date: Thu, 06 Jan 2011 11:18:20 -0800 (PST)
Message-ID: <20110106.111820.39176204.davem@davemloft.net>
References: <1294216804.19064.2.camel@mola>
	<201101051050.45381.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: axel.lin@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: florian@openwrt.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201101051050.45381.florian@openwrt.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Fainelli <florian@openwrt.org>
Date: Wed, 5 Jan 2011 10:50:45 +0100

> On Wednesday 05 January 2011 09:40:04 Axel Lin wrote:
>> Return -ENOMEM instead of 0 for the case of mdiobus_alloc and kmalloc
>> failure.
>>
>> Signed-off-by: Axel Lin <axel.lin@gmail.com>
> 
> Acked-by: Florian Fainelli <florian@openwrt.org>

Applied, thanks.
