From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net-next 0/4] Trivial enhancements for cxgb4
Date: Wed, 23 Dec 2015 12:06:27 -0500 (EST)
Message-ID: <20151223.120627.58881114140176817.davem@davemloft.net>
References: <1450850396-24141-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leedom@chelsio.com, nirranjan@chelsio.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36332 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932426AbbLWRGa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2015 12:06:30 -0500
In-Reply-To: <1450850396-24141-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Wed, 23 Dec 2015 11:29:52 +0530

> This series adds a debug message if adapter isn't inserted in right PCI
> slot. Changes naming conventions for iSCSI rx queues, use node info while
> allocating rx queue and use napi_complete_done() api in napi handler.
> 
> This patch series has been created against net-next tree and includes
> patches on cxgb4 driver.
> 
> We have included all the maintainers of respective drivers. Kindly review
> the change and let us know in case of any review comments.
> 
> Thanks
> 
> V2: Dropped 'dcb_info' debug entry patch, since the same can be achieved
>     using lldp tool.
>     Based on review comments by Or Gerlitz <gerlitz.or@gmail.com> and
>     David Miller.

Series applied, thanks.
