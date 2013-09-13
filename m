From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: GRE support for IPv6
Date: Fri, 13 Sep 2013 15:06:26 -0700
Message-ID: <20130913150626.5f9ecc3b@samsung-9>
References: <CAF0Lin0xTW4oQ0OQaTzJhoS6XV3nbb8yZx8jDMAcGyJo9zTs9A@mail.gmail.com>
	<CAF0Lin2-ooC6iQCwjnf5196cfy0Xii6H5prS4CEsjeJVAFYcyA@mail.gmail.com>
	<20130913164404.GA32431@order.stressinduktion.org>
	<2134F8430051B64F815C691A62D98318108CA3@XCH-BLV-504.nw.nos.boeing.com>
	<20130913210105.GD32431@order.stressinduktion.org>
	<20130913144630.1cb1863c@samsung-9>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"Templin, Fred L" <Fred.L.Templin@boeing.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>, xeb@mail.ru
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:43803 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753932Ab3IMWGa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Sep 2013 18:06:30 -0400
Received: by mail-pd0-f182.google.com with SMTP id r10so1790509pdi.13
        for <netdev@vger.kernel.org>; Fri, 13 Sep 2013 15:06:30 -0700 (PDT)
In-Reply-To: <20130913144630.1cb1863c@samsung-9>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 13 Sep 2013 14:46:30 -0700
Stephen Hemminger <stephen@networkplumber.org> wrote:

> On Fri, 13 Sep 2013 23:01:05 +0200
> Hannes Frederic Sowa <hannes@stressinduktion.org> wrote:
> 
> > On Fri, Sep 13, 2013 at 06:32:53PM +0000, Templin, Fred L wrote:
> > > Someone recently added the module ./net/ipv6/ip6_gre.c to the
> > > kernel, but I cannot find any obvious way to configure it using
> > > iproute2. Is there any userland code available for turning on
> > > GRE tunnels for IPv6?
> > 
> > I guess it got lost somehow:
> > 
> > http://patchwork.ozlabs.org/patch/173836/

That patch is out of date and does not apply cleanly to current iproute2
