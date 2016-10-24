From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net 1/1] net sched filters: fix notification of filter
 delete with proper handle
Date: Mon, 24 Oct 2016 10:02:29 -0700
Message-ID: <CAM_iQpVyC9X9W5sOhy+q8ycTDsspWWcCK3BLXj3a1i-kN75K9g@mail.gmail.com>
References: <1477236912-5789-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:36349 "EHLO
        mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752197AbcJXRCu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Oct 2016 13:02:50 -0400
Received: by mail-oi0-f66.google.com with SMTP id e12so2957746oib.3
        for <netdev@vger.kernel.org>; Mon, 24 Oct 2016 10:02:50 -0700 (PDT)
In-Reply-To: <1477236912-5789-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 23, 2016 at 8:35 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> From: Jamal Hadi Salim <jhs@mojatatu.com>
>
> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

We definitely need a serious changelog, even just a short one. ;)

Other than this,

Acked-by: Cong Wang <xiyou.wangcong@gmail.com>

We can address the "if (RTM_DELTFILTER != event)" in a separated patch
if needed.

Thanks.
