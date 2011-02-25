From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH iproute2] sfq: add divisor support
Date: Fri, 25 Feb 2011 13:00:45 -0800
Message-ID: <20110225130045.1e2454b3@nehalam>
References: <1295518498.2825.2.camel@edumazet-laptop>
	<20110120.165618.180427971.davem@davemloft.net>
	<1295777346.17333.26.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:44026 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752520Ab1BYVAr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Feb 2011 16:00:47 -0500
In-Reply-To: <1295777346.17333.26.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 23 Jan 2011 11:09:06 +0100
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> In 2.6.39, we can build SFQ queues with a given hash table size,
> different than default one (1024 slots)
> 
> # tc qdisc add dev eth0 sfq help
> Usage: ... sfq [ limit NUMBER ] [ perturb SECS ] [ quantum BYTES ]
>                [ divisor NUMBER ]
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied to iproute2 net-next
