From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: Linville's L2 rant... -- Re: PATCH Fix bonding active-backup behavior for VLAN interfaces
Date: Tue, 1 Aug 2006 12:52:23 -0400
Message-ID: <20060801165218.GF29208@tuxdriver.com>
References: <44CA34D0.1070507@candelatech.com> <44CA87C5.1060905@candelatech.com> <20060730.205032.130618331.davem@davemloft.net> <200607311015.40255.Christophe.Devriese@eurid.eu> <20060731123038.GA10138@tuxdriver.com> <1154396348.5170.43.camel@jzny2> <20060801120836.GA29208@tuxdriver.com> <1154435614.5170.111.camel@jzny2> <44CF7CDE.4080601@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Christophe Devriese <Christophe.Devriese@eurid.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:45837 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S1750827AbWHAQwh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2006 12:52:37 -0400
To: Ben Greear <greearb@candelatech.com>
Content-Disposition: inline
In-Reply-To: <44CF7CDE.4080601@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 01, 2006 at 09:10:06AM -0700, Ben Greear wrote:
> Jamal Hadi Salim wrote:

> >Agreed. I have some very strong opinions on this subject that i could
> >share with you if you want. For example, IMO, I think it would be a lot
> >reasonable to assume that a VLAN or VLANS are attributes of a netdevice
> >(just like IP addresses or MAC addresses are). 
> 
> As might be expected, I feel that VLANs are much more
> useful as full-featured net devices.  I do not believe it is worth
> decreasing functionality to try to 'clean up' the code.

In general, I agree that we shouldn't lose functionality.

I'm curious as to what particularly functionality you fear would be
lost if VLANs were not implemented the way they are now?

Thanks,

John
-- 
John W. Linville
linville@tuxdriver.com
