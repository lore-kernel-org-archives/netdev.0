From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 20/52] net: fealnx: remove unnecessary pci_set_drvdata()
Date: Thu, 12 Sep 2013 01:24:43 -0400 (EDT)
Message-ID: <20130912.012443.2294235053428746280.davem@davemloft.net>
References: <005e01ceaec2$23e32420$6ba96c60$%han@samsung.com>
	<5230B435.2050908@cogentembedded.com>
	<000e01ceaf4c$90cde130$b269a390$%han@samsung.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sergei.shtylyov@cogentembedded.com, netdev@vger.kernel.org
To: jg1.han@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53268 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751346Ab3ILFYr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Sep 2013 01:24:47 -0400
In-Reply-To: <000e01ceaf4c$90cde130$b269a390$%han@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jingoo Han <jg1.han@samsung.com>
Date: Thu, 12 Sep 2013 09:11:01 +0900

> Would you let know the reason not to add coding style fixes?

They should be made seperately so that the individual changes
can be reviewed more easily and without unnecessary unrelated
changes mixed in.
