From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netdev: create an "is_napi_enabled()" call
Date: Tue, 13 Nov 2007 17:42:49 -0800 (PST)
Message-ID: <20071113.174249.259628188.davem@davemloft.net>
References: <20071113230636.GJ8421@austin.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, akpm@linux-foundation.org, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net
To: linas@austin.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51283
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754262AbXKNBmu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2007 20:42:50 -0500
In-Reply-To: <20071113230636.GJ8421@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: linas@austin.ibm.com (Linas Vepstas)
Date: Tue, 13 Nov 2007 17:06:36 -0600

> 
> In certain rare cases, it can be nice to be able to check
> if napi is enabled or not. Create an is_napi_enabled() call.
> 
> Signed-off-by: Linas Vepstas <linas@austin.ibm.com>

Can you show how you'll use this?

I'm just suspicious :-)
