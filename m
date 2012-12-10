From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] virtio_net: fix a typo in
 virtnet_alloc_queues()
Date: Mon, 10 Dec 2012 13:46:58 -0500 (EST)
Message-ID: <20121210.134658.1498055886930086189.davem@davemloft.net>
References: <1355142248-19987-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jasowang@redhat.com
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58455 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751271Ab2LJSrA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Dec 2012 13:47:00 -0500
In-Reply-To: <1355142248-19987-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Mon, 10 Dec 2012 20:24:08 +0800

> Obviously it should check !vi->rq.
> 
> Reported-by: Fengguang Wu <fengguang.wu@intel.com> 
> Cc: Jason Wang <jasowang@redhat.com>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>

Applied, thanks.
