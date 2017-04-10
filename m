From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] mlxsw: convert to pci_alloc_irq_vectors
Date: Mon, 10 Apr 2017 07:06:16 -0700 (PDT)
Message-ID: <20170410.070616.478356283361143853.davem@davemloft.net>
References: <20170407130808.GA31087@splinter>
        <20170407.071405.627036901988213530.davem@davemloft.net>
        <20170410073551.GA6036@lst.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: idosch@idosch.org, jiri@mellanox.com, idosch@mellanox.com,
        netdev@vger.kernel.org
To: hch@lst.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45502 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752518AbdDJOGR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Apr 2017 10:06:17 -0400
In-Reply-To: <20170410073551.GA6036@lst.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christoph Hellwig <hch@lst.de>
Date: Mon, 10 Apr 2017 09:35:51 +0200

> On Fri, Apr 07, 2017 at 07:14:05AM -0700, David Miller wrote:
>> >> For net-next:
>> > 
>> > I noticed this is marked as "Not Applicable" in patchwork:
>> > https://patchwork.ozlabs.org/patch/747723/
>> > 
>> > But I'm not quite sure why. Maybe you meant to mark only v1?
>> > https://patchwork.ozlabs.org/patch/747674/
>> 
>> If the last patch of his series removes a kernel global API,
>> it shouldn't go via my tree.  He can send it directly to Linus
>> or via the PCI maintainer.
> 
> This is a single patch that does not remove anything.
> 
> For the different series I explicitly asked if it's okay if the whole
> thing goes in through the net tree and Bjorn was fine it.  If you're
> not it would be nice if you could state that in the series so that
> the submitter can act on it.

My bad I thought this was part of that series.

Could you do me a favor and repost that series, with this mlxsw
patch added to it.  I will apply it to net-next.

Thanks!
