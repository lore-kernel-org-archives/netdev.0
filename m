From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v1] net/smc: Add warning about remote memory
 exposure
Date: Tue, 16 May 2017 14:53:18 -0400 (EDT)
Message-ID: <20170516.145318.192117411268102702.davem@davemloft.net>
References: <20170516065138.24789-1-leon@kernel.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ubraun@linux.vnet.ibm.com, netdev@vger.kernel.org,
        iinux-rdma@vger.kernel.org, hch@lst.de
To: leon@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52396 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753315AbdEPSxf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 14:53:35 -0400
In-Reply-To: <20170516065138.24789-1-leon@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Leon Romanovsky <leon@kernel.org>
Date: Tue, 16 May 2017 09:51:38 +0300

> From: Christoph Hellwig <hch@lst.de>
> 
> The driver explicitly bypasses APIs to register all memory once a
> connection is made, and thus allows remote access to memory.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> Signed-off-by: Leon Romanovsky <leon@kernel.org>

Applied.
