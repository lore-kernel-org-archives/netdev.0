From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ehea: Increase the skb array usage
Date: Tue, 11 Jan 2011 14:04:16 -0800 (PST)
Message-ID: <20110111.140416.170112525.davem@davemloft.net>
References: <1294767957-25804-1-git-send-email-leitao@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: leitao@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43180
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754216Ab1AKWDo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Jan 2011 17:03:44 -0500
In-Reply-To: <1294767957-25804-1-git-send-email-leitao@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: leitao@linux.vnet.ibm.com
Date: Tue, 11 Jan 2011 15:45:57 -0200

> From: Breno Leitao <leitao@linux.vnet.ibm.com>
> 
> Currently the skb array is not fully allocated, and the allocation
> is done as it' s requested, which is not the expected way.
> 
> This patch just allocate the full skb array at driver initialization.
> Also, this patch increases ehea version to 107.
> 
> Signed-off-by: Breno Leitao <leitao@linux.vnet.ibm.com>

Applied.
