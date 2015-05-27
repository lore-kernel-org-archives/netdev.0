From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] cxgb4/cxgb4vf: Adds FL starvation support
 and cleanup
Date: Wed, 27 May 2015 14:27:02 -0400 (EDT)
Message-ID: <20150527.142702.2214046717700082721.davem@davemloft.net>
References: <1432746024-22065-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leedom@chelsio.com, nirranjan@chelsio.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37964 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751597AbbE0S1E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2015 14:27:04 -0400
In-Reply-To: <1432746024-22065-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Wed, 27 May 2015 22:30:22 +0530

> This patch series adds the following.
> Adds debugfs entry to inject freelist starvation and some function and
> argument cleanup
> 
> This patch series has been created against net-next tree and includes
> patches on cxgb4 and cxgb4vf driver.
> 
> We have included all the maintainers of respective drivers. Kindly review
> the change and let us know in case of any review comments.
 ...
> V2:
> Skipping patch "cxgb4: Add support for loopback between VI of same port".
> This needs some major code change, since module param is not recommended.

Series applied, thanks.
