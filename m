From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] enic: Fix build warnings
Date: Mon, 15 Nov 2010 11:13:51 -0800 (PST)
Message-ID: <20101115.111351.214216786.davem@davemloft.net>
References: <20101115180955.5779.32244.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roprabhu@cisco.com, dwang2@cisco.com
To: vkolluri@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34918
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756811Ab0KOTN0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Nov 2010 14:13:26 -0500
In-Reply-To: <20101115180955.5779.32244.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasanthy Kolluri <vkolluri@cisco.com>
Date: Mon, 15 Nov 2010 10:09:55 -0800

> From: Vasanthy Kolluri <vkolluri@cisco.com>
> 
> Fix data type of argument passed to pci_alloc_consistent and pci_free_consistent routines.
> 
> Signed-off-by: Vasanthy Kolluri <vkolluri@cisco.com>
> Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
> Signed-off-by: David Wang <dwang2@cisco.com>

Applied, thank you.
