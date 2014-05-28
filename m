From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/mlx4_core: Preserve pci_dev_data after
 __mlx4_remove_one()
Date: Tue, 27 May 2014 23:18:03 -0400 (EDT)
Message-ID: <20140527.231803.1411461924645076157.davem@davemloft.net>
References: <20140528014848.GB5830@richard>
	<20140527.193737.22275611325169063.davem@davemloft.net>
	<20140528024650.GA8602@richard>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: weiyang@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49781 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751397AbaE1DSH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 May 2014 23:18:07 -0400
In-Reply-To: <20140528024650.GA8602@richard>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yang <weiyang@linux.vnet.ibm.com>
Date: Wed, 28 May 2014 10:46:50 +0800

> Could I backport it one version by one version? Or need to send out for these
> four versions at the same time?

It's awkward for me to submit a fix for only one release, I submit a
specific set of fixes to all relevant -stable branches at one time.
