From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: GRE support for IPv6
Date: Fri, 13 Sep 2013 23:01:05 +0200
Message-ID: <20130913210105.GD32431@order.stressinduktion.org>
References: <CAF0Lin0xTW4oQ0OQaTzJhoS6XV3nbb8yZx8jDMAcGyJo9zTs9A@mail.gmail.com> <CAF0Lin2-ooC6iQCwjnf5196cfy0Xii6H5prS4CEsjeJVAFYcyA@mail.gmail.com> <20130913164404.GA32431@order.stressinduktion.org> <2134F8430051B64F815C691A62D98318108CA3@XCH-BLV-504.nw.nos.boeing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>, xeb@mail.ru,
	stephen@networkplumber.org
To: "Templin, Fred L" <Fred.L.Templin@boeing.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:56649 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753354Ab3IMVBH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Sep 2013 17:01:07 -0400
Content-Disposition: inline
In-Reply-To: <2134F8430051B64F815C691A62D98318108CA3@XCH-BLV-504.nw.nos.boeing.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 13, 2013 at 06:32:53PM +0000, Templin, Fred L wrote:
> Someone recently added the module ./net/ipv6/ip6_gre.c to the
> kernel, but I cannot find any obvious way to configure it using
> iproute2. Is there any userland code available for turning on
> GRE tunnels for IPv6?

I guess it got lost somehow:

http://patchwork.ozlabs.org/patch/173836/
