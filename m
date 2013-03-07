From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] macvlan: Set IFF_UNICAST_FLT flag to prevent
 unnecessary promisc mode.
Date: Thu, 07 Mar 2013 16:37:25 -0500 (EST)
Message-ID: <20130307.163725.1696776889298045011.davem@davemloft.net>
References: <1362687708-8685-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46470 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932822Ab3CGVh1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Mar 2013 16:37:27 -0500
In-Reply-To: <1362687708-8685-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vyasevic@redhat.com>
Date: Thu,  7 Mar 2013 15:21:48 -0500

> Macvlan already supports hw address filters.  Set the IFF_UNICAST_FLT
> so that it doesn't needlesly enter PROMISC mode when macvlans are
> stacked.
> 
> Signed-of-by: Vlad Yasevich <vyasevic@redhat.com>

Applied, thanks Vlad.
