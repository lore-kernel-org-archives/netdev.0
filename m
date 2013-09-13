From: "Templin, Fred L" <Fred.L.Templin@boeing.com>
Subject: RE: GRE support for IPv6
Date: Fri, 13 Sep 2013 23:21:24 +0000
Message-ID: <2134F8430051B64F815C691A62D98318108FCD@XCH-BLV-504.nw.nos.boeing.com>
References: <CAF0Lin0xTW4oQ0OQaTzJhoS6XV3nbb8yZx8jDMAcGyJo9zTs9A@mail.gmail.com>
	<CAF0Lin2-ooC6iQCwjnf5196cfy0Xii6H5prS4CEsjeJVAFYcyA@mail.gmail.com>
	<20130913164404.GA32431@order.stressinduktion.org>
	<2134F8430051B64F815C691A62D98318108CA3@XCH-BLV-504.nw.nos.boeing.com>
	<20130913210105.GD32431@order.stressinduktion.org>
	<20130913144630.1cb1863c@samsung-9> <20130913150626.5f9ecc3b@samsung-9>
 <2134F8430051B64F815C691A62D98318108F59@XCH-BLV-504.nw.nos.boeing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xeb@mail.ru" <xeb@mail.ru>
To: "Templin, Fred L" <Fred.L.Templin@boeing.com>,
	Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stl-mbsout-01.boeing.com ([130.76.96.169]:43208 "EHLO
	stl-mbsout-01.boeing.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755455Ab3IMXV2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Sep 2013 19:21:28 -0400
Received: from stl-mbsout-01.boeing.com (localhost.localdomain [127.0.0.1])
	by stl-mbsout-01.boeing.com (8.14.4/8.14.4/DOWNSTREAM_MBSOUT) with ESMTP id r8DNLRS3024857
	for <netdev@vger.kernel.org>; Fri, 13 Sep 2013 18:21:28 -0500
In-Reply-To: <2134F8430051B64F815C691A62D98318108F59@XCH-BLV-504.nw.nos.boeing.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> The code compiles cleanly - testing is in progress.

It works.

Fred

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-
> owner@vger.kernel.org] On Behalf Of Templin, Fred L
> Sent: Friday, September 13, 2013 3:37 PM
> To: Stephen Hemminger
> Cc: Hannes Frederic Sowa; netdev@vger.kernel.org; xeb@mail.ru
> Subject: RE: GRE support for IPv6
> 
> Hi Stephen,
> 
> See attached for the patches as applied to iproute2-3.10.0.
> The code compiles cleanly - testing is in progress.
> 
> Thanks - Fred
> 
> > -----Original Message-----
> > From: Stephen Hemminger [mailto:stephen@networkplumber.org]
> > Sent: Friday, September 13, 2013 3:06 PM
> > To: Stephen Hemminger
> > Cc: Hannes Frederic Sowa; Templin, Fred L; netdev@vger.kernel.org;
> > xeb@mail.ru
> > Subject: Re: GRE support for IPv6
> >
> > On Fri, 13 Sep 2013 14:46:30 -0700
> > Stephen Hemminger <stephen@networkplumber.org> wrote:
> >
> > > On Fri, 13 Sep 2013 23:01:05 +0200
> > > Hannes Frederic Sowa <hannes@stressinduktion.org> wrote:
> > >
> > > > On Fri, Sep 13, 2013 at 06:32:53PM +0000, Templin, Fred L wrote:
> > > > > Someone recently added the module ./net/ipv6/ip6_gre.c to the
> > > > > kernel, but I cannot find any obvious way to configure it using
> > > > > iproute2. Is there any userland code available for turning on
> > > > > GRE tunnels for IPv6?
> > > >
> > > > I guess it got lost somehow:
> > > >
> > > > http://patchwork.ozlabs.org/patch/173836/
> >
> > That patch is out of date and does not apply cleanly to current
> > iproute2
