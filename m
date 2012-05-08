From: David Miller <davem@davemloft.net>
Subject: Re: [PULL net-next] macvtap, vhost and virtio tools updates
Date: Mon, 07 May 2012 23:06:49 -0400 (EDT)
Message-ID: <20120507.230649.374018232555143645.davem@davemloft.net>
References: <20120507205537.GA27950@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org, jasowang@redhat.com
To: mst@redhat.com
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20120507205537.GA27950@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Mon, 7 May 2012 23:55:39 +0300

> There are mostly bugfixes here.
> I hope to merge some more patches by 3.5, in particular
> vlan support fixes are waiting for Eric's ack,
> and a version of tracepoint patch might be
> ready in time, but let's merge what's ready so it's testable.
> 
> This includes a ton of zerocopy fixes by Jason -
> good stuff but too intrusive for 3.4 and zerocopy is experimental
> anyway.
> 
> virtio supported delayed interrupt for a while now
> so adding support to the virtio tool made sense
> 
> Please pull into net-next and merge for 3.5.

Pulled, please give a review to:

http://patchwork.ozlabs.org/patch/156821/
http://patchwork.ozlabs.org/patch/156822/

Thanks.
