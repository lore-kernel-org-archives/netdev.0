From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net, virtio_net: replace the magic value
Date: Mon, 18 Nov 2013 16:23:28 -0500 (EST)
Message-ID: <20131118.162328.1843423306778203148.davem@davemloft.net>
References: <1384780767-25507-1-git-send-email-zwu.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mst@redhat.com, rusty@rustcorp.com.au,
	linux-kernel@vger.kernel.org, wuzhy@linux.vnet.ibm.com
To: zwu.kernel@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50090 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751343Ab3KRVXb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Nov 2013 16:23:31 -0500
In-Reply-To: <1384780767-25507-1-git-send-email-zwu.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhi Yong Wu <zwu.kernel@gmail.com>
Date: Mon, 18 Nov 2013 21:19:27 +0800

> From: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
> 
> It is more appropriate to use # of queue pairs currently used by
> the driver instead of a magic value.
> 
> Signed-off-by: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
> Acked-by: Michael S. Tsirkin <mst@redhat.com>

Applied, thanks.
