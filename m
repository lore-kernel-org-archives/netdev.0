From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 1/2] net: Add skb_get_hash_raw
Date: Thu, 16 Jan 2014 16:23:30 -0800 (PST)
Message-ID: <20140116.162330.1698441621188924836.davem@davemloft.net>
References: <alpine.DEB.2.02.1401150853090.14881@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55405 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750994AbaAQAXb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 19:23:31 -0500
In-Reply-To: <alpine.DEB.2.02.1401150853090.14881@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Wed, 15 Jan 2014 08:57:54 -0800 (PST)

> Function to just return skb->rxhash without checking to see if it needs
> to be recomputed.
> 
> Signed-off-by: Tom Herbert <therbert@google.com>

Applied.
