From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net 1/1] net sched actions: fix GETing actions
Date: Sun, 11 Sep 2016 11:56:29 -0700
Message-ID: <CAM_iQpX7hejYp3zR7AdS5CvvCvXbYreBrbX3SeAy+s0=0kHMzg@mail.gmail.com>
References: <1473336754-24930-1-git-send-email-jhs@emojatatu.com>
 <CAM_iQpUrbikYYfttzEn8AihpSmXtwrdnV-949BzVH_0DdwW37g@mail.gmail.com> <0b66983d-c316-9084-0f2c-6993cbf1f56d@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:34520 "EHLO
        mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756268AbcIKS4v (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 11 Sep 2016 14:56:51 -0400
Received: by mail-oi0-f67.google.com with SMTP id o32so1892045oik.1
        for <netdev@vger.kernel.org>; Sun, 11 Sep 2016 11:56:51 -0700 (PDT)
In-Reply-To: <0b66983d-c316-9084-0f2c-6993cbf1f56d@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 11, 2016 at 9:30 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
>
> What do you want the commit message to say? It shows an example because
> the functionality broke.

I expect it to explain why we need to increase that refcnt for GET
and how we missed it. Also need to find a right commit to blame. ;)

Thanks.
