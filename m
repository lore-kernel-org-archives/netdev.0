From: Daurnimator <quae@daurnimator.com>
Subject: Re: EINVAL when using connect() for udp sockets
Date: Mon, 4 Sep 2017 23:23:16 +1000
Message-ID: <CAEnbY+dgx0W_V2yS2L6eNFVzcSO6iQd0Y7=MKiS-+A+JsMLHtw@mail.gmail.com>
References: <CAEnbY+cYpX8naDpRkXgwCP=i64AwWgK9=_7AacmYip-ykot7mQ@mail.gmail.com>
 <CAEnbY+fPLamzXF8nOF-SEFE8LaE88XAyKNt81zs6bM866R4oGg@mail.gmail.com>
 <1490246287.16816.201.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpVVBfwd7P0-dY08Bw7QNr_w77va4AEMFj5xMuOddQoq2g@mail.gmail.com>
 <1490397560.24891.0.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpUQ52aiKQntMsrm2aMQ56G=tHCpN93A0+mffss+6m39jw@mail.gmail.com>
 <1490742712.24891.25.camel@edumazet-glaptop3.roam.corp.google.com>
 <1490748756.24891.27.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpWyQJ+XN_4mSarzHRYX4eio81G49i=wyE5MHS+AUFWU8g@mail.gmail.com>
 <1490918579.24891.82.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpXmx1GN3zvnuB6SAp9fBo_yf8G3nubGeec6tMYs4BTt2A@mail.gmail.com>
 <CAEnbY+cu_b1NddDcKMumK2npmxh4yh4kEoeeY1db2Ct3JntG9g@mail.gmail.com> <1493354932.31837.9.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        William Ahern <william@25thandclement.com>,
        "Santi T." <santitm99@gmail.com>,
        Michael Kerrisk-manpages <mtk.manpages@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f51.google.com ([209.85.218.51]:36537 "EHLO
        mail-oi0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753658AbdIDNXT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 4 Sep 2017 09:23:19 -0400
Received: by mail-oi0-f51.google.com with SMTP id t75so3706710oie.3
        for <netdev@vger.kernel.org>; Mon, 04 Sep 2017 06:23:19 -0700 (PDT)
Received: from mail-it0-f45.google.com (mail-it0-f45.google.com. [209.85.214.45])
        by smtp.gmail.com with ESMTPSA id s83sm7837242oif.39.2017.09.04.06.23.17
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Sep 2017 06:23:18 -0700 (PDT)
Received: by mail-it0-f45.google.com with SMTP id t134so9431301ita.0
        for <netdev@vger.kernel.org>; Mon, 04 Sep 2017 06:23:17 -0700 (PDT)
In-Reply-To: <1493354932.31837.9.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 28 April 2017 at 14:48, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Fri, 2017-04-28 at 12:55 +1000, Daurnimator wrote:
>> On 1 April 2017 at 03:52, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>> > Please submit your patch formally and with a man page patch too.
>>
>> Did a patch get submitted? I had a look but couldn't see it.
>
> Not yet.
>
> I will probably wait for next cycle (linux-4.13), I have been busy on
> other work lately.

Will you have time to work on this soon?
