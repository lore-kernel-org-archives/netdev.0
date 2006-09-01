From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Subject: Re: high latency with TCP connections
Date: Fri, 1 Sep 2006 15:39:37 +1200
Message-ID: <5640c7e00608312039m752be44ek85f0caa6764df853@mail.gmail.com>
References: <20060831151456.12a4e080@dxpl.pdx.osdl.net>
	 <20060831.154428.35684218.davem@davemloft.net>
	 <20060831232923.GA10036@ms2.inr.ac.ru>
	 <20060831.165701.104033558.davem@davemloft.net>
	 <20060831202309.5caefbff@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, kuznet@ms2.inr.ac.ru,
	alex@sectorb.msk.ru, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-f131.google.com ([64.233.182.131]:24825 "EHLO
	nf-out-f131.google.com") by vger.kernel.org with ESMTP
	id S1751011AbWIADjk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Aug 2006 23:39:40 -0400
Received: by nf-out-f131.google.com with SMTP id k65so39731nfa
        for <netdev@vger.kernel.org>; Thu, 31 Aug 2006 20:39:38 -0700 (PDT)
To: "Stephen Hemminger" <shemminger@osdl.org>
In-Reply-To: <20060831202309.5caefbff@localhost.localdomain>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > I'm ready to rip out ABC entirely, to be honest.  Or at least
> > turn it off by default.
>
> Turn it off for 2.6.18, by default then evaluate more for 2.6.19
>
If it goes out in 2.6.18 there could probably be a good argument for
going into the stable tree as well... to stop the likes of the JVM
type issues that users keep hitting (which is fixed or going to be
fixed by Sun).
-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
