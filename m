From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Subject: Re: [PATCH] fix inverted test in __skb_recv_datagram
Date: Tue, 08 Dec 2015 20:11:10 +0000
Message-ID: <874mfs8zvl.fsf@doppelsaurus.mobileactivedefense.com>
References: <87vb8925vx.fsf_-_@doppelsaurus.mobileactivedefense.com>
	<20151207.222827.1680789119862020474.davem@davemloft.net>
	<87h9jt809v.fsf@doppelsaurus.mobileactivedefense.com>
	<20151208.113129.263389829273977789.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rweikusat@mobileactivedefense.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tiger.mobileactivedefense.com ([217.174.251.109]:42190 "EHLO
	tiger.mobileactivedefense.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752303AbbLHULV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2015 15:11:21 -0500
In-Reply-To: <20151208.113129.263389829273977789.davem@davemloft.net> (David
	Miller's message of "Tue, 08 Dec 2015 11:31:29 -0500 (EST)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

[...]

> Please, in the future, place proper subsystem prefixes in your
> Subject lines.  In this case, "net: " would have been appropriate
> and it wouldn't be the end of the world if you capitalized
> your commit header line too.
>
> I fixed both of these things while installing your change.

Sorry. Will try to keep this in mind.
