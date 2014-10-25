From: Cong Wang <cwang@twopensource.com>
Subject: Re: [Patch net 1/2] sch_pie: schedule the timer after all init succeed
Date: Fri, 24 Oct 2014 17:28:46 -0700
Message-ID: <CAHA+R7PFSCACHyrU8fa4PVLOF1OtJiFiw4peLmFPzEu6-adaeQ@mail.gmail.com>
References: <1414194959-28006-1-git-send-email-xiyou.wangcong@gmail.com>
	<1414196222.20845.48.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Vijay Subramanian <vijaynsu@cisco.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f170.google.com ([209.85.216.170]:57318 "EHLO
	mail-qc0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932111AbaJYA2r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Oct 2014 20:28:47 -0400
Received: by mail-qc0-f170.google.com with SMTP id l6so1594866qcy.15
        for <netdev@vger.kernel.org>; Fri, 24 Oct 2014 17:28:46 -0700 (PDT)
In-Reply-To: <1414196222.20845.48.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 24, 2014 at 5:17 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> Not sure why you use "Cc: David S. Miller <davem@davemloft.net>",
> given that all networking patches have "Signed-off-by: David S. Miller
> <davem@davemloft.net>" ???
>

I don't understand what you are talking about:

If you are suggesting DaveM is too obvious to Cc, well, Cc'ing him
doesn't harm anything. I know he is on netdev list, but just in case
vger.kernel.org is broken or etc...

If you are suggesting to Cc his another email address, please update
MAINTAINERS.
