From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] net: add skb_get_tx_queue() helper
Date: Fri, 29 Aug 2014 20:02:19 -0700 (PDT)
Message-ID: <20140829.200219.1940476048656389545.davem@davemloft.net>
References: <1409130687-30871-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, netdev@vger.kernel.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52542 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750874AbaH3DCU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Aug 2014 23:02:20 -0400
In-Reply-To: <1409130687-30871-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Wed, 27 Aug 2014 11:11:27 +0200

> Replace occurences of skb_get_queue_mapping() and follow-up
> netdev_get_tx_queue() with an actual helper function.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> ---
>  v1->v2:
>   - Lets keep skb_get_tx_queue() a one-liner

Applied, thanks Daniel.
