From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/1] VSOCK: remove more space available check
 filling TX vq
Date: Fri, 12 Aug 2016 17:31:15 -0700 (PDT)
Message-ID: <20160812.173115.1043123219898818778.davem@davemloft.net>
References: <20160810152434.14346-1-ggarcia@deic.uab.cat>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stefanha@redhat.com, mst@redhat.com
To: ggarcia@abra.uab.cat
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56275 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752544AbcHMAbQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Aug 2016 20:31:16 -0400
In-Reply-To: <20160810152434.14346-1-ggarcia@deic.uab.cat>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ggarcia@abra.uab.cat
Date: Wed, 10 Aug 2016 17:24:34 +0200

> From: Gerard Garcia <ggarcia@deic.uab.cat>
> 
> Remove unnecessary use of enable/disable callback notifications
> and the incorrect more space available check.
> 
> The virtio_transport_tx_work handles when the TX virtqueue
> has more buffers available.
> 
> Signed-off-by: Gerard Garcia <ggarcia@deic.uab.cat>
> Acked-by: Stefan Hajnoczi <stefanha@redhat.com>

This does not apply cleanly to the current net GIT tree.
