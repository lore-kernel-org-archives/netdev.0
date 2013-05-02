From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PULL] vhost: cleanups and fixes for 3.10
Date: Thu, 2 May 2013 04:46:26 +0300
Message-ID: <20130502014626.GA26105@redhat.com>
References: <20130501150130.GA21230@redhat.com>
 <20130501.150548.1959140741961524114.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kvm@vger.kernel.org, virtualization@lists.osdl.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	agrover@redhat.com, asias@redhat.com, brian@purestorage.com,
	hch@lst.de, joern@logfs.org, mark.d.rustad@intel.com,
	martin.petersen@oracle.com, nab@linux-iscsi.org,
	ogerlitz@mellanox.com, yongjun_wei@trendmicro.com.cn
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59455 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759576Ab3EBBrD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 May 2013 21:47:03 -0400
Content-Disposition: inline
In-Reply-To: <20130501.150548.1959140741961524114.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 01, 2013 at 03:05:48PM -0400, David Miller wrote:
> From: "Michael S. Tsirkin" <mst@redhat.com>
> Date: Wed, 1 May 2013 18:01:31 +0300
> 
> > Please pull the following vhost core updates for 3.10 -
> > they affect both vhost-net and vhost-scsi devices.
> > They also *depend* on both net-next and target-pending.  Since Linus
> > merged target-pending but not net-next at this point, merging through
> > the net tree seems to make sense.
> 
> I don't have target-pending in my tree though and I'm not going to pull
> it in just for this.
> 
> Since you have such a multi-dependency situation, just ask Linus to pull
> this directly after I push net-next to him, which should be later today.
> 
> Thanks.

OK, thanks.
