From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: Re: [PATCH net 1/3] net: mvpp2: fix the dma_mask and
 coherent_dma_mask settings for PPv2.2
Date: Mon, 25 Sep 2017 14:40:05 +0200
Message-ID: <20170925124005.GD19364@kwain>
References: <20170918130408.23114-2-antoine.tenart@free-electrons.com>
 <20170918.171858.667084185425779267.davem@davemloft.net>
 <20170921142413.GH3568@kwain>
 <20170921.100718.386894052177530033.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: antoine.tenart@free-electrons.com, andrew@lunn.ch,
        gregory.clement@free-electrons.com,
        thomas.petazzoni@free-electrons.com,
        miquel.raynal@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, linux-kernel@vger.kernel.org,
        mw@semihalf.com, stefanc@marvell.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:42748 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935216AbdIYMkH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2017 08:40:07 -0400
Content-Disposition: inline
In-Reply-To: <20170921.100718.386894052177530033.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 21, 2017 at 10:07:18AM -0700, David Miller wrote:
> From: Antoine Tenart <antoine.tenart@free-electrons.com>
> Date: Thu, 21 Sep 2017 16:24:13 +0200
> 
> > That's also the default when the platform does not allocate dma_mask.
> 
> That's the problem that needs to be fixed then.

OK, I'll drop this patch until I find a proper solution.

Thanks,
Antoine

-- 
Antoine Ténart, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com
