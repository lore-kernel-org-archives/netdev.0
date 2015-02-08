From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net-next 0/5] Add support to dump some hw debug info
Date: Sat, 07 Feb 2015 22:54:36 -0800 (PST)
Message-ID: <20150207.225436.1287963860292537982.davem@davemloft.net>
References: <1423231375-28004-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leedom@chelsio.com, anish@chelsio.com,
	nirranjan@chelsio.com, kumaras@chelsio.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47345 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751907AbbBHGyh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Feb 2015 01:54:37 -0500
In-Reply-To: <1423231375-28004-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Fri,  6 Feb 2015 19:32:50 +0530

> This patch series adds support to dump sensor info, dump Transport Processor
> event trace, dump Upper Layer Protocol RX module command trace, dump mailbox
> contents and dump Transport Processor congestion control configuration. 
> 
> Will send a separate patch series for all the hw stats patches, by moving them
> to ethtool.
> 
> The patches series is created against 'net-next' tree.
> And includes patches on cxgb4 driver.
> 
> We have included all the maintainers of respective drivers. Kindly review the
> change and let us know in case of any review comments.
...
> V2: Dopped all hw stats related patches. Added a new patch which adds support to
> dump congestion control table. 

Series applied, thanks.
