From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] vmxnet3: fix publicity of NETIF_F_HIGHDMA
Date: Thu, 21 Jul 2011 21:34:39 -0700 (PDT)
Message-ID: <20110721.213439.1691875797734543403.davem@davemloft.net>
References: <alpine.LRH.2.00.1107202019060.27135@sbhatewara-dev1.eng.vmware.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pv-drivers@vmware.com
To: sbhatewara@vmware.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48122 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751824Ab1GVEek (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jul 2011 00:34:40 -0400
In-Reply-To: <alpine.LRH.2.00.1107202019060.27135@sbhatewara-dev1.eng.vmware.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shreyas Bhatewara <sbhatewara@vmware.com>
Date: Wed, 20 Jul 2011 20:21:51 -0700 (PDT)

> NETIF_F_HIGHDMA is being disabled even when dma64 is true. This patch fixes it.
> 
> CC: Michal Miroslaw <mirq-linux@rere.qmqm.pl>
> Signed-off-by: Shreyas N Bhatewara <sbhatewara@vmware.com>

Applied.
