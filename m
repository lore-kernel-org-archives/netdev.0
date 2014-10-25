From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Patch net 1/2] sch_pie: schedule the timer after all init
 succeed
Date: Fri, 24 Oct 2014 17:39:23 -0700
Message-ID: <1414197563.20845.50.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1414194959-28006-1-git-send-email-xiyou.wangcong@gmail.com>
	 <1414196222.20845.48.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAHA+R7PFSCACHyrU8fa4PVLOF1OtJiFiw4peLmFPzEu6-adaeQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Vijay Subramanian <vijaynsu@cisco.com>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:59543 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932111AbaJYAjZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Oct 2014 20:39:25 -0400
Received: by mail-pa0-f52.google.com with SMTP id fa1so345556pad.25
        for <netdev@vger.kernel.org>; Fri, 24 Oct 2014 17:39:25 -0700 (PDT)
In-Reply-To: <CAHA+R7PFSCACHyrU8fa4PVLOF1OtJiFiw4peLmFPzEu6-adaeQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-10-24 at 17:28 -0700, Cong Wang wrote:
> On Fri, Oct 24, 2014 at 5:17 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> >
> > Not sure why you use "Cc: David S. Miller <davem@davemloft.net>",
> > given that all networking patches have "Signed-off-by: David S. Miller
> > <davem@davemloft.net>" ???
> >
> 
> I don't understand what you are talking about:
> 
> If you are suggesting DaveM is too obvious to Cc, well, Cc'ing him
> doesn't harm anything. I know he is on netdev list, but just in case
> vger.kernel.org is broken or etc...
> 
> If you are suggesting to Cc his another email address, please update
> MAINTAINERS.


You send the patch to David Miller, as a recipient, so that he can read
it, and apply it.

You don't need to add one line in the changelog.

Why would it be needed ? Think about it.
