From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH v2] mlxsw: convert to pci_alloc_irq_vectors
Date: Mon, 10 Apr 2017 09:35:51 +0200
Message-ID: <20170410073551.GA6036@lst.de>
References: <20170406122303.30758-1-hch@lst.de> <20170406124320.GA5456@splinter.mtl.com> <20170407130808.GA31087@splinter> <20170407.071405.627036901988213530.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: idosch@idosch.org, hch@lst.de, jiri@mellanox.com,
        idosch@mellanox.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:49172 "EHLO newverein.lst.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751266AbdDJHfw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 10 Apr 2017 03:35:52 -0400
Content-Disposition: inline
In-Reply-To: <20170407.071405.627036901988213530.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 07, 2017 at 07:14:05AM -0700, David Miller wrote:
> >> For net-next:
> > 
> > I noticed this is marked as "Not Applicable" in patchwork:
> > https://patchwork.ozlabs.org/patch/747723/
> > 
> > But I'm not quite sure why. Maybe you meant to mark only v1?
> > https://patchwork.ozlabs.org/patch/747674/
> 
> If the last patch of his series removes a kernel global API,
> it shouldn't go via my tree.  He can send it directly to Linus
> or via the PCI maintainer.

This is a single patch that does not remove anything.

For the different series I explicitly asked if it's okay if the whole
thing goes in through the net tree and Bjorn was fine it.  If you're
not it would be nice if you could state that in the series so that
the submitter can act on it.
