From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] wan: dlci: Remove unused netdev_priv pointer
Date: Sun, 09 Feb 2014 18:41:36 -0800 (PST)
Message-ID: <20140209.184136.1916185682011882357.davem@davemloft.net>
References: <20140208002110.56c980e9@spike>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lizefan@huawei.com, jiri@resnulli.us
To: cengelma@gmx.at
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49224 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752381AbaBJClh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Feb 2014 21:41:37 -0500
In-Reply-To: <20140208002110.56c980e9@spike>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christian Engelmayer <cengelma@gmx.at>
Date: Sat, 8 Feb 2014 00:21:10 +0100

> Remove occurrences of unused pointer to network device private data in
> functions dlci_header() and dlci_receive().
> 
> Detected by Coverity: CID 139844, CID 139845.
> 
> Signed-off-by: Christian Engelmayer <cengelma@gmx.at>

Applied, thanks.
