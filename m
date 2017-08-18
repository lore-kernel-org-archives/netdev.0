From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Something hitting my total number of connections to the server
Date: Fri, 18 Aug 2017 05:06:24 -0700
Message-ID: <1503057984.4936.163.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CAA5aLPic9U4cwFJuTd4qBZrV=oVUSfmPzVRR_jXOBpJMU11b0A@mail.gmail.com>
         <CAA5aLPgekZJgsZV-MAD+F+ggUugQkz12D9Ef=kbP9Ev=Q1QsDw@mail.gmail.com>
         <1502879661.4936.98.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAA5aLPh0m=ZZp5kcz9h3if8kemg0QRykBpfYAnr6Bd1ptoeKKg@mail.gmail.com>
         <1502969805.4936.154.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAA5aLPjs2S0cV7MoYLB6MvZVKXomUmwpi=EVHDXh=AwR_xBqsw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Akshat Kakkar <akshat.1984@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:32855 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751267AbdHRMG2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 08:06:28 -0400
Received: by mail-pg0-f68.google.com with SMTP id u185so14802240pgb.0
        for <netdev@vger.kernel.org>; Fri, 18 Aug 2017 05:06:28 -0700 (PDT)
In-Reply-To: <CAA5aLPjs2S0cV7MoYLB6MvZVKXomUmwpi=EVHDXh=AwR_xBqsw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-08-18 at 14:44 +0530, Akshat Kakkar wrote:
> On Thu, Aug 17, 2017 at 5:06 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > On Thu, 2017-08-17 at 14:35 +0530, Akshat Kakkar wrote:
> >
> >> I upgraded to 4.4 but still experiencing same issue.
> >> Please help.
> >
> > Still too old kernel, shoot again ;)
> >
> >
> 
> 
> Sorry but that's the maximum I can try as of now as its the LT version.
> 
> Besides, this issue was not present in 2.6.32 but came with 3.10 and
> still there in 4.4, so I doubt if it has to do with some kernel and/or
> kernel parameters much as you guys are good enough not to keep an
> issue for so long (around 3 years).
> 
> So please help.

netdev is the developer list.

We deal with recent kernels only. Because we already spent time fixing
all these issues, we are not going to spend time fixing old kernels.

Please to your distro provider to backport the needed patches.
