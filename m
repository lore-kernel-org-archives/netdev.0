From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] virtio_net: use net_*_ratelimited() helpers
Date: Fri, 09 Nov 2012 17:05:56 -0500 (EST)
Message-ID: <20121109.170556.1342197808746286659.davem@davemloft.net>
References: <1352432848-16747-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rusty@rustcorp.com.au, mst@redhat.com
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38824 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756586Ab2KIWF6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Nov 2012 17:05:58 -0500
In-Reply-To: <1352432848-16747-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Fri,  9 Nov 2012 11:47:28 +0800

> These can be converted to net_*_ratelimited().
> 
> Cc: Rusty Russell <rusty@rustcorp.com.au>
> Cc: "Michael S. Tsirkin" <mst@redhat.com>
> Cc: David Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>

Applied, thanks.
