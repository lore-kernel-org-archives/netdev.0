From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/6] Free VI, flush sge ec and some other
 misc. fixes
Date: Fri, 05 Jun 2015 21:27:06 -0700 (PDT)
Message-ID: <20150605.212706.547223768540619447.davem@davemloft.net>
References: <1433494492-7638-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leedom@chelsio.com, nirranjan@chelsio.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60424 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750767AbbFFEPy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Jun 2015 00:15:54 -0400
In-Reply-To: <1433494492-7638-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Fri,  5 Jun 2015 14:24:46 +0530

> This patch series adds the following.
> Free VI interface during remove, flush SGE ec routine, rename
> t4_link_start to t4_link_l1cfg since it only does l1 configuration, set
> mac addr from when we can't contact firmware for debug purpose, set pcie
> completion timeout and use fw interface to access TP_PIO_XXX registers
> 
> This patch series has been created against net-next tree and includes
> patches on cxgb4 driver.
> 
> We have included all the maintainers of respective drivers. Kindly review
> the change and let us know in case of any review comments.

Series applied, thanks.
