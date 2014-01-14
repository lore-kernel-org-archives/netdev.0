From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ieee802154: Fix memory leak in ieee802154_add_iface()
Date: Tue, 14 Jan 2014 15:41:40 -0800 (PST)
Message-ID: <20140114.154140.627892113085276123.davem@davemloft.net>
References: <20140111221930.7255e2be@spike>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	netdev@vger.kernel.org, linux-zigbee-devel@lists.sourceforge.net
To: cengelma@gmx.at
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53522 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751384AbaANXll (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 18:41:41 -0500
In-Reply-To: <20140111221930.7255e2be@spike>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christian Engelmayer <cengelma@gmx.at>
Date: Sat, 11 Jan 2014 22:19:30 +0100

> Fix a memory leak in the ieee802154_add_iface() error handling path.
> Detected by Coverity: CID 710490.
> 
> Signed-off-by: Christian Engelmayer <cengelma@gmx.at>

Applied and queued up for -stable, thanks.
