From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] convert print_mac to %pM
Date: Mon, 27 Oct 2008 15:59:48 -0700 (PDT)
Message-ID: <20081027.155948.47818806.davem@davemloft.net>
References: <1224894099.3919.43.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54502
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750790AbYJ0XAL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Oct 2008 19:00:11 -0400
In-Reply-To: <1224894099.3919.43.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Sat, 25 Oct 2008 02:21:39 +0200

> This converts pretty much everything to print_mac. There were
> a few things that had conflicts which I have just dropped for
> now, no harm done.
> 
> I've built an allyesconfig with this and looked at the files
> that weren't built very carefully, but it's a huge patch.
> 
> Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

Applied, thanks Johannes.
