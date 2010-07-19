From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.35-rc1] net-next: vmxnet3 fixes [5/5] Respect the
 interrupt type in VM configuration
Date: Mon, 19 Jul 2010 13:16:21 -0700 (PDT)
Message-ID: <20100719.131621.172566230.davem@davemloft.net>
References: <alpine.LRH.2.00.1007131750060.32055@localhost.localdomain>
	<20100714.141118.260092331.davem@davemloft.net>
	<alpine.LRH.2.00.1007151458580.10176@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	pv-drivers@vmware.com
To: sbhatewara@vmware.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LRH.2.00.1007151458580.10176@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Shreyas Bhatewara <sbhatewara@vmware.com>
Date: Thu, 15 Jul 2010 18:21:27 -0700 (PDT)

> Respect the interrupt type set in VM configuration.
> 
> When interrupt type is not auto, do not ignore the interrupt type set from
> VM configuration.
> 
> Signed-off-by: Shreyas Bhatewara <sbhatewara@vmware.com>

Applied.
