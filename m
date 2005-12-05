From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [RFC] ip / ifconfig redesign
Date: Mon, 5 Dec 2005 15:10:03 -0500
Message-ID: <20051205200959.GF24764@tuxdriver.com>
References: <200512022253.19029.a1426z@gawab.com> <200512031646.45332.a1426z@gawab.com> <4391E4FC.1040200@candelatech.com> <20051205140057.GC24764@tuxdriver.com> <20051205174010.GA14101@buici.com> <43948049.3040508@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Marc Singer <elf@buici.com>, Al Boldi <a1426z@gawab.com>,
	netdev@vger.kernel.org, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Content-Disposition: inline
In-Reply-To: <43948049.3040508@candelatech.com>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 05, 2005 at 10:00:41AM -0800, Ben Greear wrote:
> Marc Singer wrote:
> >On Mon, Dec 05, 2005 at 09:01:00AM -0500, John W. Linville wrote:

> >>The association between IP addresses and links is already a bit murky.
> >>Reference the arp_announce sysctl for what I mean.  I recall Dave M.
> >>emphasizing on at least one occassion that IP addresses belong to
> >>the _box_, not to the link.

> >Precisely the case.  It should be the case that a box response to an
> >arp on *any* interface for *any* IP address known to the box.
> 
> I certainly don't mind if this is a configurable, or even default
> behaviour, but we also need the ability to only respond to particular

It was not my intention to derail this discussion to the arp_announce
topic.  I only cited it as an example where the IP address <->
interface mapping is not 100% absolute.

John
-- 
John W. Linville
linville@tuxdriver.com
