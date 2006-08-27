From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/7] [DCCP]: Fixes and enhancements
Date: Sat, 26 Aug 2006 21:45:24 -0700 (PDT)
Message-ID: <20060826.214524.89039745.davem@davemloft.net>
References: <200608241516.34448.ian.mcdonald@jandi.co.nz>
	<20060826.190851.74747699.davem@davemloft.net>
	<5640c7e00608262046x598d873cr7a4bcd2df971dac0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: a.bittau@cs.ucl.ac.uk, arnaldo.melo@gmail.com,
	dccp@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:35994
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751214AbWH0Epl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Aug 2006 00:45:41 -0400
To: ian.mcdonald@jandi.co.nz
In-Reply-To: <5640c7e00608262046x598d873cr7a4bcd2df971dac0@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Sun, 27 Aug 2006 15:46:58 +1200

> On 8/27/06, David Miller <davem@davemloft.net> wrote:
> > >
> > > I would love 3, 4, 5 to go into 2.6.18 as these resolve long standing CCID3
> > > issues that have been in the DCCP tree since inception and have caught a
> > > number of people.
> >
> > Ok, I'll toss 1-5 into 2.6.18
> 
> Thanks for that. Are 6 and 7 going into 2.6.19 or do you want Arnaldo
> to have a bit more of a look? 6 in particular is trivial.

Those patches are already in net-2.6.19

> Basically the implementation in the DCCP code was buggy and was
> transmitting too fast so I have made it conform to the RFC much
> closer.

Thanks for the explanation.
