From: David Miller <davem@redhat.com>
Subject: Re: remove pci_enable_msix() V3
Date: Tue, 11 Apr 2017 11:16:22 -0400 (EDT)
Message-ID: <20170411.111622.1049162642837394191.davem@redhat.com>
References: <20170411110125.3446-1-hch@lst.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhelgaas@google.com, netanel@annapurnalabs.com, jcliburn@gmail.com,
        chris.snook@gmail.com, sgoutham@cavium.com, rric@kernel.org,
        jiri@mellanox.com, idosch@mellanox.com, netdev@vger.kernel.org,
        linux-pci@vger.kernel.org
To: hch@lst.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49422 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751997AbdDKPQY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 11 Apr 2017 11:16:24 -0400
In-Reply-To: <20170411110125.3446-1-hch@lst.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christoph Hellwig <hch@lst.de>
Date: Tue, 11 Apr 2017 13:01:20 +0200

> this series removes the remaining callers of the pci_enable_msix()
> function and then the function itself.  The final removal has been
> Acked by Bjorn.
> 
> Changes since V2:
>  - add another patch on Dave's request
>  - add various acks
>  - spelling fixes in the commit logs
> 
> Changes since V1:
>  - replace the two previous thunderx patches with a new one from Thanneeru

Series applied to net-next, thanks.
