From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: remove dead code for add/del multiple
Date: Tue, 17 Dec 2013 15:14:27 -0500 (EST)
Message-ID: <20131217.151427.576275524292590944.davem@davemloft.net>
References: <20131213123556.4175da1b@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vyasevic@redhat.com, netdev@vger.kernel.org
To: shemming@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48662 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751273Ab3LQUO2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Dec 2013 15:14:28 -0500
In-Reply-To: <20131213123556.4175da1b@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemming@brocade.com>
Date: Fri, 13 Dec 2013 12:35:56 -0800

> These function to manipulate multiple addresses are not used anywhere
> in current net-next tree. Some out of tree code maybe using these but
> too bad; they should submit their code upstream..
> 
> Also, make __hw_addr_flush local since only used by dev_addr_lists.c
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Applied, thanks Stephen.
