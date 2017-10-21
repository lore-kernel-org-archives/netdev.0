From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 3/5] net/ncsi: Disable HWA mode when no channels
 are found
Date: Sat, 21 Oct 2017 01:57:10 +0100 (WEST)
Message-ID: <20171021.015710.440684340381118712.davem@davemloft.net>
References: <20171019024309.13628-1-sam@mendozajonas.com>
        <20171019024309.13628-3-sam@mendozajonas.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gwshan@linux.vnet.ibm.com,
        linux-kernel@vger.kernel.org
To: sam@mendozajonas.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171019024309.13628-3-sam@mendozajonas.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Samuel Mendoza-Jonas <sam@mendozajonas.com>
Date: Thu, 19 Oct 2017 13:43:07 +1100

> From: Gavin Shan <gwshan@linux.vnet.ibm.com>
> 
> When there are no NCSI channels probed, HWA (Hardware Arbitration)
> mode is enabled. It's not correct because HWA depends on the fact:
> NCSI channels exist and all of them support HWA mode. This disables
> HWA when no channels are probed.
> 
> Signed-off-by: Gavin Shan <gwshan@linux.vnet.ibm.com>
> Signed-off-by: Samuel Mendoza-Jonas <sam@mendozajonas.com>

Applied.
