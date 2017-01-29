From: David Miller <davem@davemloft.net>
Subject: Re: pull-request: can 2017-01-27
Date: Sun, 29 Jan 2017 18:46:06 -0500 (EST)
Message-ID: <20170129.184606.7321731386358543.davem@davemloft.net>
References: <20170127204627.11735-1-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org,
        kernel@pengutronix.de
To: mkl@pengutronix.de
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <20170127204627.11735-1-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Marc Kleine-Budde <mkl@pengutronix.de>
Date: Fri, 27 Jan 2017 21:46:26 +0100

> this is a pull request for net/master.
> 
> It consists of a single patch by Eric Dumazet, it fixes a kernel panic at
> security_sock_rcv_skb.

Oops, I applied Eric's patch directly since you ACK'd it.
