From: Ido Schimmel <idosch@idosch.org>
Subject: Re: [PATCH v2] mlxsw: convert to pci_alloc_irq_vectors
Date: Thu, 6 Apr 2017 15:43:20 +0300
Message-ID: <20170406124320.GA5456@splinter.mtl.com>
References: <20170406122303.30758-1-hch@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jiri@mellanox.com, idosch@mellanox.com, netdev@vger.kernel.org
To: Christoph Hellwig <hch@lst.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:56264 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1755996AbdDFMnW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Apr 2017 08:43:22 -0400
Content-Disposition: inline
In-Reply-To: <20170406122303.30758-1-hch@lst.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 06, 2017 at 02:23:03PM +0200, Christoph Hellwig wrote:
> Trivial conversion as only one vector is supported, but at least we
> lose the useless msix_entry member in the per-device structure.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

For net-next:

Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Tested-by: Ido Schimmel <idosch@mellanox.com>

Thanks!
