From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] virtio_net: large tx MTU support
Date: Wed, 26 Nov 2008 15:28:20 -0800 (PST)
Message-ID: <20081126.152820.52837825.davem@davemloft.net>
References: <1227707891.9579.44.camel@blaa>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rusty@rustcorp.com.au, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: markmc@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55619
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752353AbYKZX2U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2008 18:28:20 -0500
In-Reply-To: <1227707891.9579.44.camel@blaa>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark McLoughlin <markmc@redhat.com>
Date: Wed, 26 Nov 2008 13:58:11 +0000

> We don't really have a max tx packet size limit, so allow configuring
> the device with up to 64k tx MTU.
> 
> Signed-off-by: Mark McLoughlin <markmc@redhat.com>

Rusty, ACK?

If so, I'll toss this into net-next-2.6, thanks!
