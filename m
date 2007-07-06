From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] skbuff: remove export of static symbol
Date: Thu, 05 Jul 2007 17:03:26 -0700 (PDT)
Message-ID: <20070705.170326.10964069.davem@davemloft.net>
References: <1183627981.3818.26.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48866
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754853AbXGFADI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jul 2007 20:03:08 -0400
In-Reply-To: <1183627981.3818.26.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes@sipsolutions.net>
Date: Thu, 05 Jul 2007 11:33:01 +0200

> skb_clone_fraglist is static so it shouldn't be exported.
> 
> Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

Patch applied, thanks!
