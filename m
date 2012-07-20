From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 00/16] Remove the ipv4 routing cache
Date: Sat, 21 Jul 2012 00:05:59 +0200
Message-ID: <1342821959.2626.8052.camel@edumazet-glaptop>
References: <20120720.142502.1144557295933737451.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:43905 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751618Ab2GTWGF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2012 18:06:05 -0400
Received: by wibhm11 with SMTP id hm11so1001547wib.1
        for <netdev@vger.kernel.org>; Fri, 20 Jul 2012 15:06:03 -0700 (PDT)
In-Reply-To: <20120720.142502.1144557295933737451.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-07-20 at 14:25 -0700, David Miller wrote:
> [ Ok I'm going to be a little bit cranky, and I think I deserve it.
> 
>   I'm basically not going to go through the multi-hour rebase and
>   retest process again, as it's hit the point of diminishing returns
>   as NOBODY is giving me test results but I can guarentee that
>   EVERYONE will bitch and complain when I push this into net-next and
>   it breaks their favorite feature.  If you can't be bothered to test
>   these changes, I'm honestly going to tell people to take a hike and
>   fix it themselves.  I simply don't care if you don't care enough to
>   test changes of this magnitude to make sure your favorite setup
>   still works.
> 
>   To say that I'm disappointed with the amount of testing feedback
>   after posting more than a dozen iterations of this delicate patch
>   set would be an understatement.  I can think of only one person who
>   actually tested one iteration of these patches and gave feedback.
> 
>   And meanwhile I've personally reviewed, tested, and signed off on
>   everyone else's work WITHOUT DELAY during this entire process.
> 
>   I've pulled 25 hour long hacking shifts to make that a reality, so
>   that my routing cache removal work absolutely would not impact or
>   delay the patch submissions of any other networking developer.  And
>   I can't even get a handful of testers with some feedback?  You
>   really have to be kidding me.. ]

Hmm, ok, please give me few hours to make some tests ;)
