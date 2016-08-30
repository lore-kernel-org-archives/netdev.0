From: Vinod Koul <vinod.koul@intel.com>
Subject: Re: [PATCH 1/8] dmaengine: sa11x0: add DMA filters
Date: Tue, 30 Aug 2016 21:27:29 +0530
Message-ID: <20160830155729.GI9355@localhost>
References: <20160829112540.GF1041@n2100.armlinux.org.uk>
 <E1beKhY-0001Gn-PB@rmk-PC.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dmaengine@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        netdev@vger.kernel.org, Dan Williams <dan.j.williams@intel.com>,
        Samuel Ortiz <samuel@sortiz.org>
To: Russell King <rmk+kernel@armlinux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:17167 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751708AbcH3Pt1 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 30 Aug 2016 11:49:27 -0400
Content-Disposition: inline
In-Reply-To: <E1beKhY-0001Gn-PB@rmk-PC.armlinux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 29, 2016 at 12:26:04PM +0100, Russell King wrote:
> Add DMA filters for the sa11x0 DMA channels.  This will allow us to
> migrate away from directly using the DMA filter function in drivers.

Acked-by: Vinod Koul <vinod.koul@intel.com>

-- 
~Vinod
