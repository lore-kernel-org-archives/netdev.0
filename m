From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/3] Bug fixes for cxgb4 and cxgb4vf
Date: Mon, 29 Apr 2013 15:25:28 -0400 (EDT)
Message-ID: <20130429.152528.135092242474665135.davem@davemloft.net>
References: <1367244281-23043-1-git-send-email-vipul@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, divy@chelsio.com, dm@chelsio.com,
	abhishek@chelsio.com, leedom@chelsio.com,
	swise@opengridcomputing.com
To: vipul@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33548 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933413Ab3D2TZb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Apr 2013 15:25:31 -0400
In-Reply-To: <1367244281-23043-1-git-send-email-vipul@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vipul Pandya <vipul@chelsio.com>
Date: Mon, 29 Apr 2013 19:34:38 +0530

> This patch series does the following:
> 1. Passes correct PF number during initialization of pci_device_id structure
> 2. Adds code in cxgb4 and cxgb4vf driver to handle CPL_SGE_EGR_UPDATE message
>    encapsulated in a CPL_FW4_MSG.
> 
> We would like to request this patch series to get merged via David Miller's
> 'net' tree.

It doesn't even apply to the 'net' tree, you prepared it against 'net-next'
so that's where I applied it.

The tree it goes into is immatierial right now anyways as I'm preparing for
the merge window.
