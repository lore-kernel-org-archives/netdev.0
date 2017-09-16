From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: Use after free in __dst_destroy_metrics_generic
Date: Sat, 16 Sep 2017 11:13:40 -0700
Message-ID: <CAM_iQpWUHj7isjCqqe-Kvi46kzeqaDy_1WFkmsG4-qXBhznG7A@mail.gmail.com>
References: <1234e09b75197d43ed84bdb1b154b4b6@codeaurora.org>
 <CAM_iQpXKfUkbyuuZEZXyPrVVCoPaxnCmCARz=Jf0VtU1m9NsZg@mail.gmail.com> <1505509219.16139.6.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Lorenzo Colitti <lorenzo@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f48.google.com ([74.125.83.48]:54576 "EHLO
        mail-pg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751253AbdIPSOB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 16 Sep 2017 14:14:01 -0400
Received: by mail-pg0-f48.google.com with SMTP id c137so3096181pga.11
        for <netdev@vger.kernel.org>; Sat, 16 Sep 2017 11:14:01 -0700 (PDT)
In-Reply-To: <1505509219.16139.6.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 15, 2017 at 2:00 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> Hi Cong
>
> I believe your patch makes a lot of sense, please submit it formally ?
>

I have been waiting for Subash's testing, since I myself never even run it.
