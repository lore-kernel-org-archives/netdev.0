From: Ido Schimmel <idosch@mellanox.com>
Subject: Re: [PATCH] mlxsw: convert to pci_alloc_irq_vectors
Date: Thu, 6 Apr 2017 14:27:14 +0300
Message-ID: <20170406112714.GA26250@splinter.mtl.com>
References: <20170406094023.2710-1-hch@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <jiri@mellanox.com>, <netdev@vger.kernel.org>
To: Christoph Hellwig <hch@lst.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr40074.outbound.protection.outlook.com ([40.107.4.74]:28672
        "EHLO EUR03-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753861AbdDFL1X (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 6 Apr 2017 07:27:23 -0400
Content-Disposition: inline
In-Reply-To: <20170406094023.2710-1-hch@lst.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 06, 2017 at 11:40:23AM +0200, Christoph Hellwig wrote:
> Trivial conversion as only one vector is supported, but at least we
> lose the useless msix_entry member in the per-device structure.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

It doesn't apply cleanly to net-next. Can you please re-spin?

Thanks
