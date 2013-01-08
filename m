From: Cong Wang <amwang@redhat.com>
Subject: Re: [PATCH net-next v4 0/3] netpoll: add IPv6 support
Date: Tue, 08 Jan 2013 13:15:08 +0800
Message-ID: <1357622108.3544.9.camel@cr0>
References: <1357543036-15492-1-git-send-email-amwang@redhat.com>
	 <20130107.194621.1068055780988116658.davem@davemloft.net>
	 <1357617351.3544.8.camel@cr0>
	 <20130107.205430.1462325504640202248.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:30662 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750740Ab3AHFnL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jan 2013 00:43:11 -0500
In-Reply-To: <20130107.205430.1462325504640202248.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-01-07 at 20:54 -0800, David Miller wrote:
> From: Cong Wang <amwang@redhat.com>
> Date: Tue, 08 Jan 2013 11:55:51 +0800
> 
> > udp6_csum_init() is not a big function, so I see no reason why it
> > can't be inlined.
> 
> I say it is.

Ok. Then I will create a new file to put udp6_csum_init().

Thanks!
