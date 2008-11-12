From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: remove struct dst_entry::entry_size
Date: Tue, 11 Nov 2008 17:25:40 -0800 (PST)
Message-ID: <20081111.172540.136370985.davem@davemloft.net>
References: <20081111132445.GA14810@x200.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38277
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751839AbYKLBZk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2008 20:25:40 -0500
In-Reply-To: <20081111132445.GA14810@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Tue, 11 Nov 2008 16:24:45 +0300

> Unused after kmem_cache_zalloc() conversion.
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Applied.
