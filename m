From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net-next 0/6] Trivial fixes and changes for SGE
Date: Tue, 05 May 2015 19:32:10 -0400 (EDT)
Message-ID: <20150505.193210.1312592296343501716.davem@davemloft.net>
References: <1430818196-26508-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leedom@chelsio.com, nirranjan@chelsio.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57971 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754996AbbEEXcL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2015 19:32:11 -0400
In-Reply-To: <1430818196-26508-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Tue,  5 May 2015 14:59:50 +0530

> This patch series adds the following.
> Discard packet if length is greater than MTU, move sge monitor code to a
> new routine, add device node to ULD info, add congestion notification from
> SGE for ingress queue and freelists and for T5, setting up the Congestion
> Manager values of the new RX Ethernet Queue is done by firmware now.
> 
> This patch series has been created against net-next tree and includes
> patches on cxgb4 driver.
> 
> We have included all the maintainers of respective drivers. Kindly review
> the change and let us know in case of any review comments.
> 
> Thanks
> 
> V2: Align parenthesis for PATCH 2/6 and PATCH 5/6

Series applied, thank you.
