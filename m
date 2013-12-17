From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2 0/8] qlcnic: Bug fixes.
Date: Tue, 17 Dec 2013 16:25:50 -0500 (EST)
Message-ID: <20131217.162550.911509655767676884.davem@davemloft.net>
References: <cover.1387256276.git.himanshu.madhani@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com
To: himanshu.madhani@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49182 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751390Ab3LQVZv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Dec 2013 16:25:51 -0500
In-Reply-To: <cover.1387256276.git.himanshu.madhani@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Himanshu Madhani <himanshu.madhani@qlogic.com>
Date: Mon, 16 Dec 2013 15:36:55 -0500

> This series contains bug fixes for mailbox handling and multi Tx queue support
> for all supported adapters.
> 
> changes from v1 -> v2
> o updated patch to fix usage of netif_tx_{wake,stop} api during link change
>   as per David Miller's suggestion.
> o Dropped patch to use spinklock per tx queue for more work.
> o Added reworked patch for memory allocation failures.
> o Added patch to allow capturing of dump, when auto recovery is disabled in firmware.
> o Added patches for mailbox interrupt handling and debugging data for mailbox failure.
> 
> Please apply to net.

Series applied, thank you.
