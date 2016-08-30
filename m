From: Vinod Koul <vinod.koul@intel.com>
Subject: Re: [PATCH 4/8] dmaengine: sa11x0: unexport sa11x0_dma_filter_fn and
 clean up
Date: Tue, 30 Aug 2016 21:28:28 +0530
Message-ID: <20160830155828.GJ9355@localhost>
References: <20160829112540.GF1041@n2100.armlinux.org.uk>
 <E1beKho-0001H5-TA@rmk-PC.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dmaengine@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        netdev@vger.kernel.org, Dan Williams <dan.j.williams@intel.com>,
        Samuel Ortiz <samuel@sortiz.org>
To: Russell King <rmk+kernel@armlinux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:40716 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753438AbcH3PuZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 30 Aug 2016 11:50:25 -0400
Content-Disposition: inline
In-Reply-To: <E1beKho-0001H5-TA@rmk-PC.armlinux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 29, 2016 at 12:26:20PM +0100, Russell King wrote:
> As we now have no users of sa11x0_dma_filter_fn() in the tree, we can
> unexport this function, and remove the now unused header file.

Acked-by: Vinod Koul <vinod.koul@intel.com>


-- 
~Vinod
