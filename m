From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH v6 0/5] XDP for virtio_net
Date: Sat, 17 Dec 2016 11:56:35 -0500 (EST)
Message-ID: <20161217.115635.1434636952919136886.davem@davemloft.net>
References: <20161216011620-mutt-send-email-mst@kernel.org>
        <20161216.132002.2295377318615583719.davem@davemloft.net>
        <20161216224600-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: john.fastabend@gmail.com, daniel@iogearbox.net,
        netdev@vger.kernel.org, alexei.starovoitov@gmail.com,
        john.r.fastabend@intel.com, brouer@redhat.com, tgraf@suug.ch
To: mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41660 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750780AbcLQQ4i (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 17 Dec 2016 11:56:38 -0500
In-Reply-To: <20161216224600-mutt-send-email-mst@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Fri, 16 Dec 2016 22:48:14 +0200

> On Fri, Dec 16, 2016 at 01:20:02PM -0500, David Miller wrote:
>> From: "Michael S. Tsirkin" <mst@redhat.com>
>> Date: Fri, 16 Dec 2016 01:17:44 +0200
>> 
>> > OK, I think we can queue this for -next.
>> > 
>> > It's fairly limited in the kind of hardware supported, we can and
>> > probably should extend it further with time.
>> > 
>> > Acked-by: Michael S. Tsirkin <mst@redhat.com>
>> 
>> Michael, thanks for reviewing.
>> 
>> Since the substance of this patch series has honestly been ready since
>> before the merge window, would you mind if I send this to Linus now?
>> 
>> That's what I was hoping I would be able to do.
>> 
>> Thanks again.
> 
> ACK, no problem.
> BTW in case people wonder, I'll be offline for a couple of weeks.
> This might delay review of some patches a bit.

Great, series applied, thanks everyone!
