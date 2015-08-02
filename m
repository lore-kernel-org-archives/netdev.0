From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next] virtio_net: add gro capability
Date: Sun, 2 Aug 2015 11:48:35 +0300
Message-ID: <20150802114823-mutt-send-email-mst@redhat.com>
References: <1438359917.2748.18.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150731.165732.2136164140565390142.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, rick.jones2@hp.com,
	virtualization@lists.linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57093 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751828AbbHBIsj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 2 Aug 2015 04:48:39 -0400
Content-Disposition: inline
In-Reply-To: <20150731.165732.2136164140565390142.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 31, 2015 at 04:57:32PM -0700, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Fri, 31 Jul 2015 18:25:17 +0200
> 
> > From: Eric Dumazet <edumazet@google.com>
> > 
> > Straightforward patch to add GRO processing to virtio_net.
> > 
>  ...
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> > Tested-by: Rick Jones <rick.jones2@hp.com>
> > Cc: "Michael S. Tsirkin" <mst@redhat.com>
> 
> Michael, please review :-)

Will do shortly :)
