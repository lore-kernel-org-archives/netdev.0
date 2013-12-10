From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/5] ipv6: remove rcv_tclass of ipv6_pinfo
Date: Mon, 09 Dec 2013 21:04:20 -0500 (EST)
Message-ID: <20131209.210420.1138474819647066396.davem@davemloft.net>
References: <1386514021-11646-1-git-send-email-florent.fourcot@enst-bretagne.fr>
	<1386514021-11646-3-git-send-email-florent.fourcot@enst-bretagne.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: florent.fourcot@enst-bretagne.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45084 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751887Ab3LJCEV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Dec 2013 21:04:21 -0500
In-Reply-To: <1386514021-11646-3-git-send-email-florent.fourcot@enst-bretagne.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
Date: Sun,  8 Dec 2013 15:46:59 +0100

> tclass information in now already stored in rcv_flowinfo
> We do not need to store the same information twice.
> 
> Signed-off-by: Florent Fourcot <florent.fourcot@enst-bretagne.fr>

Applied.
