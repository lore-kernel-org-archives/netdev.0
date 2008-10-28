From: David Miller <davem@davemloft.net>
Subject: Re: convert more to %pM
Date: Mon, 27 Oct 2008 17:50:06 -0700 (PDT)
Message-ID: <20081027.175006.228597002.davem@davemloft.net>
References: <1224894906.3919.45.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, joe@perches.com
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58539
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751723AbYJ1Au2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Oct 2008 20:50:28 -0400
In-Reply-To: <1224894906.3919.45.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Sat, 25 Oct 2008 02:35:06 +0200

> A number of places still use %02x:...:%02x because it's
> in debug statements or for no real reason. Make a few
> of them use %pM.
> 
> Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

Applied, thanks!
