From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -stable] virtio-net: drop NETIF_F_FRAGLIST
Date: Tue, 10 Nov 2015 15:11:26 -0500 (EST)
Message-ID: <20151110.151126.611293958922280322.davem@davemloft.net>
References: <1447179965.2645.5.camel@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: 3chas3@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33358 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751123AbbKJUL2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Nov 2015 15:11:28 -0500
In-Reply-To: <1447179965.2645.5.camel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Charles (Chas) Williams" <3chas3@gmail.com>
Date: Tue, 10 Nov 2015 13:26:05 -0500

> Dave, could you please add
> 
> commit 48900cb6af4282fa0fb6ff4d72a81aa3dadb5c39
> virtio-net: drop NETIF_F_FRAGLIST
> 
> to your stable queues for 3.14.y and 4.1.y?

Ok, queued up.
