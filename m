From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netlink: advertise incomplete dumps
Date: Mon, 20 Jun 2011 13:59:29 -0700 (PDT)
Message-ID: <20110620.135929.942453687487758741.davem@davemloft.net>
References: <1308570046.4322.5.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	samuel@sortiz.org, aloisio.almeida@openbossa.org,
	linville@tuxdriver.com, tgraf@suug.ch
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33090 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752344Ab1FTVCv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2011 17:02:51 -0400
In-Reply-To: <1308570046.4322.5.camel@jlt3.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Mon, 20 Jun 2011 13:40:46 +0200

> Should we merge this through wireless? From wireless-next it'll go into
> net-next quickly, but the converse isn't true, so using it in wireless
> would be harder if it was merged through net-next I think? Or John can
> cherry-pick into wireless-testing?

I'm fine with this going in via the wireless tree, that way we'll
see a real user when it merged into net-next-2.6

Acked-by: David S. Miller <davem@davemloft.net>
