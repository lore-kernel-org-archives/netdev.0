From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next 0/1] Introduction of the tc tests
Date: Mon, 19 Jun 2017 16:37:29 -0700
Message-ID: <CAM_iQpUxfGrLTv+8J_=n2-zOOd5fqwrNSvF7Ro1EyRyBBNb_8w@mail.gmail.com>
References: <1497648155-25521-1-git-send-email-lucasb@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Jiri Pirko <jiri@resnulli.us>, Roman Mashak <mrv@mojatatu.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: Lucas Bates <lucasb@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33220 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752546AbdFSXhv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Jun 2017 19:37:51 -0400
Received: by mail-wm0-f68.google.com with SMTP id f90so19651992wmh.0
        for <netdev@vger.kernel.org>; Mon, 19 Jun 2017 16:37:50 -0700 (PDT)
In-Reply-To: <1497648155-25521-1-git-send-email-lucasb@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Fri, Jun 16, 2017 at 2:22 PM, Lucas Bates <lucasb@mojatatu.com> wrote:
> Apologies for sending this as one big patch. I've been sitting on this a little
> too long, but it's ready and I wanted to get it out.
>
> There are a limited number of tests to start - I plan to add more on a regular
> basis.
>
> Lucas Bates (1):
>   selftests: Introduce tc testsuite

Nice work!

Is there any particular reason you want to put these tests in kernel tree
especially tools/testing/selftests/ ?
