From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] virtio: document queue state logic
Date: Mon, 06 Apr 2015 16:44:49 -0400 (EDT)
Message-ID: <20150406.164449.1091214597663452067.davem@davemloft.net>
References: <20150402125743-mutt-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rusty@rustcorp.com.au, virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org, stephen@networkplumber.org
To: mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48326 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753062AbbDFUov (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Apr 2015 16:44:51 -0400
In-Reply-To: <20150402125743-mutt-send-email-mst@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Thu, 2 Apr 2015 13:05:47 +0200

> commit d631b94e7a15277858ec5f88d674d93080506999
>     virtio: change comment in transmit
> 
> started clarifying the logic behind queue state management,
> but introduced an inaccuracy: TX_BUSY does not cause
> a BUG message.
> 
> Clean this up some more, explaining the tradeoffs in detail.
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

Applied, thanks Michael.
