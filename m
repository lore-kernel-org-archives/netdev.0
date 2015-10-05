From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv3 net-next 0/4] cxgb4: Trivial fixes for cxgb4
Date: Mon, 05 Oct 2015 03:51:23 -0700 (PDT)
Message-ID: <20151005.035123.617026778484482371.davem@davemloft.net>
References: <1443687528-25836-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leedom@chelsio.com, nirranjan@chelsio.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39013 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753029AbbJEKfo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 06:35:44 -0400
In-Reply-To: <1443687528-25836-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Thu,  1 Oct 2015 13:48:44 +0530

> Fixes the following issues
> Don't read non existent T4/T5/T6 adapter registers for ethtool dump.
> For T4, dont read mailbox control registers. Adds new devlog faility and
> report correct link speed for unsupported ones.
> 
> This patch series has been created against net-next tree and includes
> patches on cxgb4 driver.
> 
> We have included all the maintainers of respective drivers. Kindly review
> the change and let us know in case of any review comments.
> 
> Thanks
> 
> V3: Add an "<unread>" entry to char *owner[] array so the index of "4"
>  makes sense, based on review comment by Casey Leedom <leedom@chelsio.com>
> V2: Fix coding style for Patch2/4 ("cxgb4: For T4, don't read the Firmware
>  Mailbox Control register") based on review comment by Sergei Shtylyov

Series applied, thanks.
