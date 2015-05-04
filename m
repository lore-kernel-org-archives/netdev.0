From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Suspicious RCU usage in bridge with Linux
 v4.0-9362-g1fc149933fd4
Date: Mon, 04 May 2015 15:29:10 -0700
Message-ID: <1430778550.27254.10.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CA+5PVA5gE_pG5iPKBgugsEjLsOYvq9bWKfB+2OeEujjdOb+URg@mail.gmail.com>
	 <20150504133943.GA17043@x131e>
	 <CAHA+R7PAzzz+CZfnOoweBdeLY8tRkr2bSDEpQgdtEKUeaZbWpQ@mail.gmail.com>
	 <1430772572.27254.3.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAHA+R7OD7Bh52MkB1hKs8DdncrgBN2_1VYQwrFGetJFJ7chgyg@mail.gmail.com>
	 <1430777167.27254.8.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAHA+R7OrtnPuNX+qa_o4MArL2Sc8T9jALp5tyQYFMv4dxUeF7A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Dominick Grift <dac.override@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f177.google.com ([209.85.223.177]:34003 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751177AbbEDW3M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2015 18:29:12 -0400
Received: by iedfl3 with SMTP id fl3so160057371ied.1
        for <netdev@vger.kernel.org>; Mon, 04 May 2015 15:29:11 -0700 (PDT)
In-Reply-To: <CAHA+R7OrtnPuNX+qa_o4MArL2Sc8T9jALp5tyQYFMv4dxUeF7A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-05-04 at 15:17 -0700, Cong Wang wrote:
> On Mon, May 4, 2015 at 3:06 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > On Mon, 2015-05-04 at 14:38 -0700, Cong Wang wrote:
> >
> >> Compile-test only patch is never ready for review, I thought it is too obvious
> >> to mention.
> >
> > Thats not relevant.
> >
> > Obvious or not, you are not making things easy for reviewers.
> >
> 
> Why should I make a NOT-ready-for-review patch easy for reviewers?
> What's the point here? I don't have the right to choose my patch NOT
> to be reviewed? Huh...
> 

Look, I only said :

"Please send inline patches, otherwise its hard for us to review them
and give feedback."

I gave a quite reasonable request, with a "Please"


I was not expecting this becoming a war.

Next time, I will let David deal with your patches.
