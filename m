From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ifdef struct sock::sk_async_wait_queue
Date: Wed, 12 Nov 2008 23:25:40 -0800 (PST)
Message-ID: <20081112.232540.131705331.davem@davemloft.net>
References: <20081112121308.GA4759@x200.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@netdev.vger.kernel.org, netdev@vger.kernel.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36442
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751516AbYKMHZk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2008 02:25:40 -0500
In-Reply-To: <20081112121308.GA4759@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Wed, 12 Nov 2008 15:13:08 +0300

> Every user is under CONFIG_NET_DMA already, so ifdef field as well.
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Applied, thanks Alexey.
