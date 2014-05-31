From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/mlx4_core: Preserve pci_dev_data after
 __mlx4_remove_one()
Date: Fri, 30 May 2014 23:35:49 -0700 (PDT)
Message-ID: <20140530.233549.1224347263965890953.davem@davemloft.net>
References: <20140528024650.GA8602@richard>
	<20140527.231803.1411461924645076157.davem@davemloft.net>
	<20140531024654.GA12848@richard>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: weiyang@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34654 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751371AbaEaGfw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 May 2014 02:35:52 -0400
In-Reply-To: <20140531024654.GA12848@richard>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yang <weiyang@linux.vnet.ibm.com>
Date: Sat, 31 May 2014 10:46:54 +0800

> I have back port code to 3.14, 3.10 and verified.
> 
> While on 3.4, this kernel version doesn't work on our latest machine.
> This is a latest Power Machine. I don't have a spare x86 machine to verify
> this card. And this card is in US, while I am in China.
> 
> Is it possible to send out the code without verification? And ask help from
> others, like Mellanox engineer? Otherwise this would be a little trouble.

Just do a best effort backport and make sure it compiles cleanly.
