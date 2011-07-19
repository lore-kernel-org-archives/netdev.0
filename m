From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/45] Update bna driver version to 3.0.2.0
Date: Tue, 19 Jul 2011 16:24:07 -0700 (PDT)
Message-ID: <20110719.162407.220839918648336520.davem@davemloft.net>
References: <E5313AF6F2BFD14293E5FD0F94750F86A83BDF4A00@HQ1-EXCH01.corp.brocade.com>
	<20110718.185805.413849001475627611.davem@davemloft.net>
	<E5313AF6F2BFD14293E5FD0F94750F86A83BDF4C07@HQ1-EXCH01.corp.brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, adapter_linux_open_src_team@brocade.com
To: rmody@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:39706 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751561Ab1GSXZO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jul 2011 19:25:14 -0400
In-Reply-To: <E5313AF6F2BFD14293E5FD0F94750F86A83BDF4C07@HQ1-EXCH01.corp.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rasesh Mody <rmody@brocade.com>
Date: Tue, 19 Jul 2011 15:53:06 -0700

> We can further split the submission into multiple smaller
> submissions (e.g. 4 patches a time as you suggested), but there
> still will be one big patch set for new hardware and feature
> enablement

That's fine, just don't add the patch that causes the driver
to recognize the new device IDs until all the necessary
support code is there.
