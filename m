From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] vlan: static functions
Date: Wed, 14 Dec 2011 02:47:26 -0500 (EST)
Message-ID: <20111214.024726.1951159044503679507.davem@davemloft.net>
References: <1323845874.2846.22.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bcrl@kvack.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54530 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753726Ab1LNHrb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Dec 2011 02:47:31 -0500
In-Reply-To: <1323845874.2846.22.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 14 Dec 2011 07:57:54 +0100

> commit 6d4cdf47d2 (vlan: add 802.1q netpoll support) forgot to declare
> as static some private functions.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
