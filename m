From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: remove struct neigh_table::pde
Date: Tue, 11 Nov 2008 17:24:15 -0800 (PST)
Message-ID: <20081111.172415.52884299.davem@davemloft.net>
References: <20081111120740.GC30773@x200.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38275
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751536AbYKLBYQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2008 20:24:16 -0500
In-Reply-To: <20081111120740.GC30773@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Tue, 11 Nov 2008 15:07:40 +0300

> ->pde isn't actually needed, since name is stashed in ->id.
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Applied, thanks.
