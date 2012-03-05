From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vmxnet3: Fix log messages and corrects some typos
Date: Sun, 04 Mar 2012 21:38:05 -0500 (EST)
Message-ID: <20120304.213805.1561116862946405222.davem@davemloft.net>
References: <alpine.LRH.2.00.1202282209500.19873@sbhatewara-dev1.eng.vmware.com>
	<1330498925.4352.13.camel@joe2Laptop>
	<alpine.LRH.2.00.1202282343130.19873@sbhatewara-dev1.eng.vmware.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, netdev@vger.kernel.org, pv-drivers@vmware.com,
	petr@vmware.com
To: sbhatewara@vmware.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47813 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751228Ab2CECiW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Mar 2012 21:38:22 -0500
In-Reply-To: <alpine.LRH.2.00.1202282343130.19873@sbhatewara-dev1.eng.vmware.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shreyas Bhatewara <sbhatewara@vmware.com>
Date: Wed, 29 Feb 2012 00:08:39 -0800 (PST)

> Fix log messages and corrects some typos
> 
> Change logging of failure to enable MSI/MSI-X to display device's PCI
> address instead of eth%d. Rectify a typo.
> 
> Signed-off-by: Shreyas N Bhatewara <sbhatewara@vmware.com>
> Reviewed-by: Joe Perches <joe@perches.com>

Applied, thanks.
