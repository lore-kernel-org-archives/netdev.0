From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] virtio_net: add gro capability
Date: Fri, 31 Jul 2015 16:57:32 -0700 (PDT)
Message-ID: <20150731.165732.2136164140565390142.davem@davemloft.net>
References: <1438359917.2748.18.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rick.jones2@hp.com, mst@redhat.com,
	virtualization@lists.linux-foundation.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52006 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753790AbbGaX5f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jul 2015 19:57:35 -0400
In-Reply-To: <1438359917.2748.18.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 31 Jul 2015 18:25:17 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> Straightforward patch to add GRO processing to virtio_net.
> 
 ...
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Tested-by: Rick Jones <rick.jones2@hp.com>
> Cc: "Michael S. Tsirkin" <mst@redhat.com>

Michael, please review :-)
