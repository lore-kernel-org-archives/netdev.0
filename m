From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Subject: Re: [PATCH 0/7] [DCCP]: Fixes and enhancements
Date: Sun, 27 Aug 2006 16:57:17 +1200
Message-ID: <5640c7e00608262157w33f4f3c8scb24b527d629f169@mail.gmail.com>
References: <200608241516.34448.ian.mcdonald@jandi.co.nz>
	 <20060826.190851.74747699.davem@davemloft.net>
	 <5640c7e00608262046x598d873cr7a4bcd2df971dac0@mail.gmail.com>
	 <20060826.214524.89039745.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: a.bittau@cs.ucl.ac.uk, arnaldo.melo@gmail.com,
	dccp@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-f131.google.com ([64.233.184.131]:43110 "EHLO
	wr-out-f131.google.com") by vger.kernel.org with ESMTP
	id S1751257AbWH0E5S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Aug 2006 00:57:18 -0400
Received: by wr-out-f131.google.com with SMTP id 20so86145wra
        for <netdev@vger.kernel.org>; Sat, 26 Aug 2006 21:57:17 -0700 (PDT)
To: "David Miller" <davem@davemloft.net>
In-Reply-To: <20060826.214524.89039745.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > On 8/27/06, David Miller <davem@davemloft.net> wrote:
> > > >
> > > > I would love 3, 4, 5 to go into 2.6.18 as these resolve long standing CCID3
> > > > issues that have been in the DCCP tree since inception and have caught a
> > > > number of people.
> > >
> > > Ok, I'll toss 1-5 into 2.6.18
> >
> > Thanks for that. Are 6 and 7 going into 2.6.19 or do you want Arnaldo
> > to have a bit more of a look? 6 in particular is trivial.
>
> Those patches are already in net-2.6.19
>
Yes I see that now. However I can't see #5 in net-2.6.git in your tree
or Linus' where 1-4 made it in...

Ian
-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
