From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: dev: Convert printks to pr_<level>
Date: Wed, 01 Feb 2012 14:43:05 -0500 (EST)
Message-ID: <20120201.144305.251984620339115457.davem@davemloft.net>
References: <1327882830.2652.16.camel@joe2Laptop>
	<20120201.142156.871464551711177387.davem@davemloft.net>
	<1328125229.18641.17.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1328125229.18641.17.camel@joe2Laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Wed, 01 Feb 2012 11:40:29 -0800

> Do you prefer coalesced formats in all cases?
> 
> 		pr_warn("Number of in use tx queues changed invalidating tc mappings. Priority traffic classification disabled!\n");

It seems to be the new trend, so yes.
