From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/5]qlcnic: Multiple Tx queue support and
 code refactoring
Date: Mon, 04 Nov 2013 15:34:13 -0500 (EST)
Message-ID: <20131104.153413.1652033517527668390.davem@davemloft.net>
References: <cover.1383612975.git.himanshu.madhani@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com
To: himanshu.madhani@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54147 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752839Ab3KDUeP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Nov 2013 15:34:15 -0500
In-Reply-To: <cover.1383612975.git.himanshu.madhani@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Himanshu Madhani <himanshu.madhani@qlogic.com>
Date: Mon, 4 Nov 2013 13:31:28 -0500

> From: Himanshu Madhani <himanshu.madhani@qlogic.com>
> 
> This Patch series contains following changes
> 
> o Refactored code to calculate, validate and assign Tx/SDS rings for  various modes of driver.
> o Enhanced ethtool statistics for multi Tx queue on all supported adapters.
> o Enable multiple Tx queue for 83xx and 84xx Series adapters.
> o Register netdev for failed device state.
> 
> changes from v1 -> v2
> o Dropped patch to replace inappropriate usage of kzalloc() with vzalloc().
> 
> Please apply to net-next.

Series applied, thanks.
