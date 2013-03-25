From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] virtio: remove obsolete virtqueue_get_queue_index()
Date: Sun, 24 Mar 2013 21:51:10 -0400 (EDT)
Message-ID: <20130324.215110.1406536052480990199.davem@davemloft.net>
References: <87fvzke45u.fsf@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46159 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754996Ab3CYBvN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Mar 2013 21:51:13 -0400
In-Reply-To: <87fvzke45u.fsf@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rusty Russell <rusty@rustcorp.com.au>
Date: Mon, 25 Mar 2013 10:33:57 +1030

> You can access it directly now, since 3.8: v3.7-rc1-13-g06ca287
> 'virtio: move queue_index and num_free fields into core struct
> virtqueue.'
> 
> (Handing to DaveM for Ack or just take it...)
> 
> Cc: Cornelia Huck <cornelia.huck@de.ibm.com>
> Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
> Acked-by: Cornelia Huck <cornelia.huck@de.ibm.com>

This is already in my net-next tree.
