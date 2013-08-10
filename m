From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] ipv6: don't stop backtracking in fib6_lookup_1 if subtree does not match
Date: Sat, 10 Aug 2013 14:15:30 +0200
Message-ID: <20130810121530.GQ14001@order.stressinduktion.org>
References: <20130807003431.GD16410@order.stressinduktion.org> <EF96A1CB-549E-474A-AF58-10F2D2F2BF4A@inf-net.nl> <20130807200637.GD32257@order.stressinduktion.org> <26D8997F-7CDF-425A-B0DC-4D57996871E5@inf-net.nl> <20130809141939.GL14001@order.stressinduktion.org> <CF3AE072-7B80-4C35-9236-4523EE11629F@inf-net.nl> <20130809145743.GM14001@order.stressinduktion.org> <2A0809D4-EBF1-4646-9564-2B7F54956B41@inf-net.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Teco Boot <teco@inf-net.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:43303 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758248Ab3HJMPc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Aug 2013 08:15:32 -0400
Content-Disposition: inline
In-Reply-To: <2A0809D4-EBF1-4646-9564-2B7F54956B41@inf-net.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 10, 2013 at 01:39:12PM +0200, Teco Boot wrote:
> The hang problem in 3.8.0-28 has lower priority for me. Maybe I'll check current -net-next later. Don't hold your breath.

Ah, one more thing: Please don't test net-next but net
<https://git.kernel.org/cgit/linux/kernel/git/davem/net.git/>.

All relevant patches are in there. They will first show up in net-next when
David merges net back to net-next. That's because the other patches are also
queued up for 3.11 inclusion.

Greetings,

  Hannes
