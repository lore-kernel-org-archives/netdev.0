From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 3/3] ipv6: protect flow label renew against
 GC
Date: Fri, 08 Nov 2013 13:44:46 -0500 (EST)
Message-ID: <20131108.134446.1777912116659233195.davem@davemloft.net>
References: <1383843194-22945-1-git-send-email-florent.fourcot@enst-bretagne.fr>
	<1383843194-22945-3-git-send-email-florent.fourcot@enst-bretagne.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: florent.fourcot@enst-bretagne.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36055 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757039Ab3KHSos (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Nov 2013 13:44:48 -0500
In-Reply-To: <1383843194-22945-3-git-send-email-florent.fourcot@enst-bretagne.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
Date: Thu,  7 Nov 2013 17:53:14 +0100

> Take ip6_fl_lock before to read and update
> a label.
> 
> v2: protect only the relevant code
> 
> Reported-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Signed-off-by: Florent Fourcot <florent.fourcot@enst-bretagne.fr>

Applied.
