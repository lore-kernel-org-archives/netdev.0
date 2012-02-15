From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/7] mlx4: Bug fixes and cleanups
Date: Wed, 15 Feb 2012 02:18:36 -0500 (EST)
Message-ID: <20120215.021836.1107074571403936200.davem@davemloft.net>
References: <74A0102445410646AFACC089FD94803A5CEEACB5@MTLDAG02.mtl.com>
	<20120214.152238.470074857804516115.davem@davemloft.net>
	<953B660C027164448AE903364AC447D25D0B68A1@MTLDAG02.mtl.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eugenia@mellanox.com, netdev@vger.kernel.org
To: yevgenyp@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:53066 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757625Ab2BOHSp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2012 02:18:45 -0500
In-Reply-To: <953B660C027164448AE903364AC447D25D0B68A1@MTLDAG02.mtl.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yevgeny Petrilin <yevgenyp@mellanox.com>
Date: Wed, 15 Feb 2012 06:54:07 +0000

>> 
>> > Some of the patches fix very harmful memory leaks and corruptions.
>> 
>> Then submit the patches properly, don't mix cleanups in there if it matters so much to you.
> 
> We will split the series in 2 parts, 1 for net and the other for net-next

I already applied all of them to net-next.  So submitting any of them
for net-next would be superfluous.
