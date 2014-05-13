From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [next PATCH 0/5] net: tcp: DCTCP congestion control algorithm -
 IPR Patent Issue
Date: Tue, 13 May 2014 18:02:37 +0200
Message-ID: <CAPh34me6C2hzrqqADTHPs35TGfVwOjL3NBQD1pG57OXssvM4wg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: lars@netapp.com, Cong Wang <cwang@twopensource.com>,
	Florian Westphal <fw@strlen.de>,
	netdev <netdev@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f175.google.com ([209.85.128.175]:39976 "EHLO
	mail-ve0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752757AbaEMQCi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2014 12:02:38 -0400
Received: by mail-ve0-f175.google.com with SMTP id jw12so707116veb.34
        for <netdev@vger.kernel.org>; Tue, 13 May 2014 09:02:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13 May 2014 17:18, Stephen Hemminger <stephen@networkplumber.org> wrote:

> This is not enough to allow distribution under GPL.
> GPL has patent and redistribution clauses that as far as I know
> are not compatible.

Sure? IANAL, but as far as I know there is no such thing as "licence a
*patent* under the GPL". Furthermore, GPLv2 state: "To prevent this,
we have made it clear that any patent must be licensed for everyone's
free use or not licensed at all." - this is fulfilled in my opinion.

 I assume larger parts of the kernel are randomly covered by patents
to some degree. The "advantage" here is that we know for sure that we
can use this code without any potential patent claims (the good news
in a bad world).

But let other people decide if there is a problem with this particular IPR.


Hagen
