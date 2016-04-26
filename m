From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/8] cxgb4: minor fixes, decode msgs and code
 refactor for few functions
Date: Tue, 26 Apr 2016 13:24:15 -0400 (EDT)
Message-ID: <20160426.132415.1192784825272545399.davem@davemloft.net>
References: <1461681629-28275-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leedom@chelsio.com,
	swise@opengridcomputing.com, nirranjan@chelsio.com,
	santosh@chelsio.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40438 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751363AbcDZRYS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2016 13:24:18 -0400
In-Reply-To: <1461681629-28275-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Tue, 26 Apr 2016 20:10:21 +0530

> This patch series adds new routine to get adapter information and removes
> some redundant messages logged in dmesg. Fixes race while freeing tx
> descriptors. Decodes module type and link down reason codes obtained from
> firmware. Refactor port initialization and FW_PORT_CMD handling. Pass
> correct port id in DCB message handler to obtain netdev associated. 
> 
> This patch series has been created against net-next tree and includes
> patches on cxgb4 driver.
> 
> We have included all the maintainers of respective drivers. Kindly review
> the change and let us know in case of any review comments.

Series applied, thanks.
