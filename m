From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] Use new BAR2 GTS for T5, adds adaptive rx
 and few Device ID's
Date: Sun, 28 Sep 2014 17:34:59 -0400 (EDT)
Message-ID: <20140928.173459.2097603390562807474.davem@davemloft.net>
References: <1411671235-6527-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leedom@chelsio.com, kumaras@chelsio.com,
	nirranjan@chelsio.com, santosh@chelsio.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47719 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753397AbaI1VfB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Sep 2014 17:35:01 -0400
In-Reply-To: <1411671235-6527-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Fri, 26 Sep 2014 00:23:51 +0530

> This patch series adds support to use new BAR2 GTS for T5 adapter.
> Adds support for adaptive rx. Remove redundant variable from a macro of
> cxgb4vf driver. Adds Device ID for new adapters.
> 
> The patches series is created against 'net-next' tree.
> And includes patches on cxgb4 and cxgb4vf driver.
> 
> We have included all the maintainers of respective drivers. Kindly review the
> change and let us know in case of any review comments.

Series applied, thanks.
