From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: ICMP rate limiting in IPv4 but not in IPv6
Date: Fri, 13 Sep 2013 22:40:16 +0200
Message-ID: <20130913204016.GC32431@order.stressinduktion.org>
References: <CAF0Lin0xTW4oQ0OQaTzJhoS6XV3nbb8yZx8jDMAcGyJo9zTs9A@mail.gmail.com> <CAF0Lin2-ooC6iQCwjnf5196cfy0Xii6H5prS4CEsjeJVAFYcyA@mail.gmail.com> <20130913164404.GA32431@order.stressinduktion.org> <CAOp4FwQ6YWpMtZ9-64tVDc29RhtiUjwinQjZ32mjEu_pZfRHHA@mail.gmail.com> <20130913181712.GA29989@order.stressinduktion.org> <CAF0Lin0WvJU8W1LErQjs+ZRq8_mrwX7femuByvM3i7VhQrdbpw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Loganaden Velvindron <loganaden@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Andy Johnson <johnsonzjo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:56612 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754679Ab3IMUkR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Sep 2013 16:40:17 -0400
Content-Disposition: inline
In-Reply-To: <CAF0Lin0WvJU8W1LErQjs+ZRq8_mrwX7femuByvM3i7VhQrdbpw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 13, 2013 at 09:26:08PM +0300, Andy Johnson wrote:
> Hello,
> 
> My question was out of pure interest and not because of any practical
> need. However, preparing a patch for supporting rate limiting for
> ICMPv6 is easy and I am ready to do it. I want to know before, what
> other people think about it - is it needed ?

*shrug*

I don't know. I haven't needed it yet but could think of artificial
situations where it could be handy. :)
