From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2] vmxnet3: round down # of queues to power of two
Date: Thu, 07 Jul 2011 00:26:00 -0700 (PDT)
Message-ID: <20110707.002600.1893726460035682706.davem@davemloft.net>
References: <alpine.LRH.2.00.1107061751120.3509@sbhatewara-dev1.eng.vmware.com>
	<alpine.LRH.2.00.1107061813100.3509@sbhatewara-dev1.eng.vmware.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pv-drivers@vmware.com, netdev@vger.kernel.org, dtor@vmware.com,
	yongwang@vmware.com
To: sbhatewara@vmware.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:52955 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751716Ab1GGH0C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2011 03:26:02 -0400
In-Reply-To: <alpine.LRH.2.00.1107061813100.3509@sbhatewara-dev1.eng.vmware.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shreyas Bhatewara <sbhatewara@vmware.com>
Date: Wed, 6 Jul 2011 18:16:53 -0700 (PDT)

> 
> vmxnet3 device supports only power-of-two number of queues. The driver
> therefore needs to check this and rounds down the number of queues to the
> nearest power of two.
> 
> Signed-off-by: Yong Wang <yongwang@vmware.com>
> Signed-off-by: Shreyas N Bhatewara <sbhatewara@vmware.com>
> Reviewed-by: Dmitry Torokhov <dtor@vmware.com>

Applied.
