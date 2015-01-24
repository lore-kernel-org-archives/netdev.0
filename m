From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/6] netns: advertise netns via netlink
Date: Fri, 23 Jan 2015 17:51:42 -0800 (PST)
Message-ID: <20150123.175142.618148236781483266.davem@davemloft.net>
References: <1421763347-4354-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52854 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752910AbbAXBvn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2015 20:51:43 -0500
In-Reply-To: <1421763347-4354-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Tue, 20 Jan 2015 15:15:41 +0100

> 
> The first patch of the serie fix a bug of the previous serie (present in
> net-next only).
> The rest of the serie adds an attribute to advertise the peer netns for
> rtnetlink messages where this information is needed by userland to be able to
> interpret fully the received message.

"series" has a final 's'.  Well, as least you consistently misspell it
3 times :-)

"Series" applied, thanks!
