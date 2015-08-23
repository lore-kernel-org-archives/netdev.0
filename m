From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net/xen-netfront: only clean up queues if
 present
Date: Sun, 23 Aug 2015 15:56:36 -0700 (PDT)
Message-ID: <20150823.155636.530305773311103437.davem@davemloft.net>
References: <1440026060.2546.9.camel@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: 3chas3@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47006 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753711AbbHWW4h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Aug 2015 18:56:37 -0400
In-Reply-To: <1440026060.2546.9.camel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Charles (Chas) Williams" <3chas3@gmail.com>
Date: Wed, 19 Aug 2015 19:14:20 -0400

> From: Chas Williams <3chas3@gmail.com>
> 
> If you simply load and unload the module without starting the interfaces,
> the queues are never created and you get a bad pointer dereference.
> 
> Signed-off-by: Chas Williams <3chas3@gmail.com>

Applied, thanks Chas.
