From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: IPv6 nexthop for IPv4
Date: Thu, 26 Mar 2015 13:17:20 -0400
Message-ID: <20150326171719.GE1051@gospo>
References: <CAJO99T=uXuaYP5QCRYbU7iRhK7S8UqW9GfmL1J2yBh1N2TDjYg@mail.gmail.com>
 <CACP96tQnQ5d2qrPbs+S640S=r07vnbt-RmL_O2zT7Wcvg99dug@mail.gmail.com>
 <CAJO99TmhNARZL4L2KzMHLdqhXFh8LYb+mussWvaiCN4KQpim=Q@mail.gmail.com>
 <CACP96tQAYZEq=cFyDNBkgzUbJ_VPJB540ZxgaRqpciujCYOjsA@mail.gmail.com>
 <CAJO99Tm+ex7aELCrNnubWz1hGjELMp0LCMKSqtyr+Vci1hrmuw@mail.gmail.com>
 <20150326154336.GA2528@tuxdriver.com>
 <20150326162756.GC1051@gospo>
 <1427387871.25985.139.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville@tuxdriver.com>,
	=?iso-8859-1?Q?Bj=F8rnar?= Ness <bjornar.ness@gmail.com>,
	Sowmini Varadhan <sowmini05@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f49.google.com ([209.85.213.49]:35726 "EHLO
	mail-yh0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751749AbbCZRR1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2015 13:17:27 -0400
Received: by yhim52 with SMTP id m52so29435702yhi.2
        for <netdev@vger.kernel.org>; Thu, 26 Mar 2015 10:17:26 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1427387871.25985.139.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 26, 2015 at 09:37:51AM -0700, Eric Dumazet wrote:
> On Thu, 2015-03-26 at 12:27 -0400, Andy Gospodarek wrote:
> 
> > Yes, I do have one!  I was working on some other issues and need to
> > rebase it based on Eric's recent work.  It was fairly simple and the
> > netlink changes are also not too difficult so the patch to iproute2 was
> > small.
> > 
> > I have an older patch you can see here:
> > 
> > https://github.com/gospo/net-next/commit/7f602a54424f453872b6a45ae5ed4d3a601db91d
> > 
> > Shall I rebase and post to the list for all to see?
> 
> Absolutely !
> 

Enthusiasm appreciated!

Rebasing and testing now.
