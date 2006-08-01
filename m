From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: Linville's L2 rant... -- Re: PATCH Fix bonding active-backup behavior for VLAN interfaces
Date: Tue, 1 Aug 2006 12:48:33 -0400
Message-ID: <20060801164827.GE29208@tuxdriver.com>
References: <44CA34D0.1070507@candelatech.com> <44CA87C5.1060905@candelatech.com> <20060730.205032.130618331.davem@davemloft.net> <200607311015.40255.Christophe.Devriese@eurid.eu> <20060731123038.GA10138@tuxdriver.com> <1154396348.5170.43.camel@jzny2> <20060801120836.GA29208@tuxdriver.com> <1154435614.5170.111.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Christophe Devriese <Christophe.Devriese@eurid.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:42509 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S1750811AbWHAQsz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2006 12:48:55 -0400
To: Jamal Hadi Salim <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1154435614.5170.111.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 01, 2006 at 08:33:34AM -0400, Jamal Hadi Salim wrote:
> On Tue, 2006-01-08 at 08:08 -0400, John W. Linville wrote:

> > And, I think that a
> > reconsideration of all three functions as a group could lead to
> > better/cleaner functionality with easier support for extension (e.g.
> > 802.1s).
> 
> Agreed. I have some very strong opinions on this subject that i could
> share with you if you want. For example, IMO, I think it would be a lot
> reasonable to assume that a VLAN or VLANS are attributes of a netdevice
> (just like IP addresses or MAC addresses are). 

I'd love to hear them.  Feel free to send them off list, since I know
how shy you can be... :-)

John
-- 
John W. Linville
linville@tuxdriver.com
