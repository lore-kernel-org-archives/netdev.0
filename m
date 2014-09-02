From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v1 0/4] amd-xgbe: AMD XGBE driver fixes 2014-08-29
Date: Mon, 01 Sep 2014 20:40:08 -0700 (PDT)
Message-ID: <20140901.204008.676727285574353037.davem@davemloft.net>
References: <20140829181643.3257.28011.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: thomas.lendacky@amd.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46900 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751925AbaIBDkK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2014 23:40:10 -0400
In-Reply-To: <20140829181643.3257.28011.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Lendacky <thomas.lendacky@amd.com>
Date: Fri, 29 Aug 2014 13:16:44 -0500

> The following series of patches includes fixes to the driver.
> 
> - Tx hardware queue flushing support dependent on hardware version
> - Incorrect reported fifo size
> - Proper mmd select in XPCS debugfs support
> - Proper queue count for configuring Tx flow control
> 
> This patch series is based on net.

Series applied, thanks.
