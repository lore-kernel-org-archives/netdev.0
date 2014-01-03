From: David Miller <davem@davemloft.net>
Subject: Re: spin_unlock is missed in function (netpoll_send_skb_on_dev) in
 file (linux-3.12/net/core/netpoll.c)
Date: Fri, 03 Jan 2014 15:50:18 -0500 (EST)
Message-ID: <20140103.155018.1759974817523071637.davem@davemloft.net>
References: <CAFZT-jLtQNZnsoWO8nzJ0i5qUE6J--wXhg+gUXvh4qdmxMG4=g@mail.gmail.com>
	<CAFZT-jLEyU2taPCypVPoV=U8GSVKbqeAB5U+8VtWLnLOKjjZEg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ahmedtamrawi@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34210 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752756AbaACUuT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jan 2014 15:50:19 -0500
In-Reply-To: <CAFZT-jLEyU2taPCypVPoV=U8GSVKbqeAB5U+8VtWLnLOKjjZEg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Stephen already forwarded your report to the list and I already fixed
it last night.
