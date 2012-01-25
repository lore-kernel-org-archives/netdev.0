From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] vmxnet3: cleanup tso headers manipulation
Date: Wed, 25 Jan 2012 16:53:19 -0500 (EST)
Message-ID: <20120125.165319.107361716933605134.davem@davemloft.net>
References: <1327470441.14373.37.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sbhatewara@vmware.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:53017 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752468Ab2AYVxW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2012 16:53:22 -0500
In-Reply-To: <1327470441.14373.37.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 25 Jan 2012 06:47:21 +0100

> Use existing helpers to clarify skb headers manipulation.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Shreyas Bhatewara <sbhatewara@vmware.com>

Applied.
