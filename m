From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 1/1] SCHED: netem: Correct documentation comment in
 code.
Date: Thu, 11 Dec 2008 09:21:51 -0800
Message-ID: <20081211092151.6c8fb81e@s6510>
References: <1229001489.18280.179.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jesper Dangaard Brouer <hawk@comx.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:52969 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755954AbYLKRV5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Dec 2008 12:21:57 -0500
In-Reply-To: <1229001489.18280.179.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 11 Dec 2008 14:18:09 +0100
Jesper Dangaard Brouer <hawk@comx.dk> wrote:

> 
> The netem simulator is no longer limited by Linux timer resolution HZ.
> Not since Patrick McHardy changed the QoS system to use hrtimer.
> 
> Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>

That depends if HIGH_RES_TIMERS are configured.

Acked-by: Stephen Hemminger <shemminger@vyatta.com>
