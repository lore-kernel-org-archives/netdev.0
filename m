From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 0/6] net: stmmac: make DMA programmable burst length
 more configurable
Date: Thu, 08 Dec 2016 13:07:29 -0500 (EST)
Message-ID: <20161208.130729.608166810889379996.davem@davemloft.net>
References: <1481120409-18103-1-git-send-email-niklass@axis.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, niklass@axis.com,
        devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-doc@vger.kernel.org
To: niklas.cassel@axis.com
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1481120409-18103-1-git-send-email-niklass@axis.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Niklas Cassel <niklas.cassel@axis.com>
Date: Wed, 7 Dec 2016 15:20:02 +0100

> Make DMA programmable burst length more configurable in the stmmac driver.
> 
> This is done by adding support for independent pbl for tx/rx through DT.
> More fine grained tuning of pbl is possible thanks to a DT property saying
> that we should NOT multiply pbl values by x8/x4 in hardware.
> 
> All new DT properties are optional, and created in a way that it will not
> affect any existing DT configurations.

Series applied to net-next, thanks.
