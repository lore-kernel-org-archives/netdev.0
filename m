From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [next PATCH 0/5] net: tcp: DCTCP congestion control algorithm -
 IPR Patent Issue
Date: Tue, 13 May 2014 09:10:19 -0700
Message-ID: <20140513091019.7b1efbef@nehalam.linuxnetplumber.net>
References: <CAPh34me6C2hzrqqADTHPs35TGfVwOjL3NBQD1pG57OXssvM4wg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: lars@netapp.com, Cong Wang <cwang@twopensource.com>,
	Florian Westphal <fw@strlen.de>,
	netdev <netdev@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:48510 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752120AbaEMQKY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2014 12:10:24 -0400
Received: by mail-pa0-f43.google.com with SMTP id hz1so450554pad.16
        for <netdev@vger.kernel.org>; Tue, 13 May 2014 09:10:23 -0700 (PDT)
In-Reply-To: <CAPh34me6C2hzrqqADTHPs35TGfVwOjL3NBQD1pG57OXssvM4wg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 13 May 2014 18:02:37 +0200
Hagen Paul Pfeifer <hagen@jauu.net> wrote:

> On 13 May 2014 17:18, Stephen Hemminger <stephen@networkplumber.org> wrote:
> 
> > This is not enough to allow distribution under GPL.
> > GPL has patent and redistribution clauses that as far as I know
> > are not compatible.
> 
> Sure? IANAL, but as far as I know there is no such thing as "licence a
> *patent* under the GPL". Furthermore, GPLv2 state: "To prevent this,
> we have made it clear that any patent must be licensed for everyone's
> free use or not licensed at all." - this is fulfilled in my opinion.
> 
>  I assume larger parts of the kernel are randomly covered by patents
> to some degree. The "advantage" here is that we know for sure that we
> can use this code without any potential patent claims (the good news
> in a bad world).
> 
> But let other people decide if there is a problem with this particular IPR.
> 
> 
> Hagen

IANAL but my understanding is that FRAND and GPL are not by nature directly
compatible. It is possible for do it but only if the entity claiming IPR
gives a free license to all GPL users. This is the case of the recent Cisco
PIE implementation for example.
