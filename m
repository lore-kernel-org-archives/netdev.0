From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] overhaul node action flags
Date: Fri, 09 May 2014 01:41:33 -0400 (EDT)
Message-ID: <20140509.014133.290035406849365172.davem@davemloft.net>
References: <1399510480-29558-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, Paul.Gortmaker@windriver.com,
	erik.hugne@ericsson.com, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net
To: ying.xue@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33519 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751124AbaEIFlq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2014 01:41:46 -0400
In-Reply-To: <1399510480-29558-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ying Xue <ying.xue@windriver.com>
Date: Thu, 8 May 2014 08:54:38 +0800

> We currently have two problems with the node flags field:
>  - The naming of the individual action flags is unclear and confusing
>  - The flags are often not cleared individually,  making it hard to follow
>    where this happens.
> 
> So the series aims to solve above two problems.

Series applied, thanks.
