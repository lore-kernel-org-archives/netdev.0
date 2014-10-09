From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] cxgb4/cxgb4vf: Misc fixes and 40G support
 for cxgb4vf
Date: Thu, 09 Oct 2014 18:55:59 -0400 (EDT)
Message-ID: <20141009.185559.756024011555918969.davem@davemloft.net>
References: <1412813927-24951-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leedom@chelsio.com, kumaras@chelsio.com,
	nirranjan@chelsio.com, santosh@chelsio.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43665 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751065AbaJIW4B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2014 18:56:01 -0400
In-Reply-To: <1412813927-24951-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Thu,  9 Oct 2014 05:48:44 +0530

> This patch series adds 40G support for cxgb4vf driver. Update the LSO length for
> cxgb4vf, fix macro. Wait for device to get ready before reading PL_WHOAMI
> register.
> 
> The patches series is created against 'net-next' tree.
> And includes patches on cxgb4 and cxgb4vf driver.
> 
> We have included all the maintainers of respective drivers. Kindly review the
> change and let us know in case of any review comments.

Series applied, thanks.
