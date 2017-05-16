From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] liquidio: use pcie_flr instead of duplicating it
Date: Tue, 16 May 2017 16:00:00 -0400 (EDT)
Message-ID: <20170516.160000.1677155549929964398.davem@davemloft.net>
References: <20170516142146.21739-1-hch@lst.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: felix.manlunas@caviumnetworks.com,
        raghu.vatsavayi@caviumnetworks.com,
        satananda.burla@caviumnetworks.com,
        derek.chickles@caviumnetworks.com, netdev@vger.kernel.org
To: hch@lst.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53146 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750949AbdEPUAC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 16:00:02 -0400
In-Reply-To: <20170516142146.21739-1-hch@lst.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christoph Hellwig <hch@lst.de>
Date: Tue, 16 May 2017 16:21:46 +0200

> Signed-off-by: Christoph Hellwig <hch@lst.de>
> Tested-by: Felix Manlunas <felix.manlunas@cavium.com>

Applied to net-next, thanks.
