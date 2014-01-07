From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] tipc: link setup and failover improvements
Date: Tue, 07 Jan 2014 18:45:08 -0500 (EST)
Message-ID: <20140107.184508.1028018727000763031.davem@davemloft.net>
References: <1389132164-32451-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paul.gortmaker@windriver.com,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net
To: jon.maloy@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46001 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754375AbaAGXpP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jan 2014 18:45:15 -0500
In-Reply-To: <1389132164-32451-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Maloy <jon.maloy@ericsson.com>
Date: Tue,  7 Jan 2014 17:02:40 -0500

> This series consists of four unrelated commits with different purposes.
> 
> - Commit #1 is purely cosmetic and pedagogic, hopefully making the
>   failover/tunneling logics slightly easier to understand. 
> - Commit #2 fixes a bug that has always been in the code, but was not
>   discovered until very recently.
> - Commit #3 fixes a non-fatal race issue in the neighbour discovery
>   code.
> - Commit #4 removes an unnecessary indirection step during link 
>   startup.

Series applied, thank you.
