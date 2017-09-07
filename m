From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: Can you help to analyze this panic issue when using VPN?
Date: Thu, 7 Sep 2017 14:20:03 -0700
Message-ID: <CAM_iQpXx6+oo8tLR3t125XF6kKCF8mpiLQdM=H_Dj9cUts9RLQ@mail.gmail.com>
References: <3B91CCFCFC433E4596591DB9A191998574452FE9@nkgeml514-mbx.china.huawei.com>
 <CANn89iLWa7bL+WdWzdQXLhFGpORf3ZmyRoi3Pp2XLKS3O4skNw@mail.gmail.com> <3B91CCFCFC433E4596591DB9A191998574453125@nkgeml514-mbx.china.huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "weiwan@google.com" <weiwan@google.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "Wanghao (R)" <zidane.wanghao@huawei.com>,
        sunjilong <sunjilong1@huawei.com>,
        "Liwei (Sirius)" <sirius.liwei@huawei.com>,
        sangguanlin <sangguanlin@huawei.com>,
        "Xuhui (hunter, Device company )" <hunter.xuhui@huawei.com>,
        Eric Dumazet <edumazet@google.com>
To: Songchuan <songchuan@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f54.google.com ([74.125.83.54]:35980 "EHLO
        mail-pg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752708AbdIGVUZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 7 Sep 2017 17:20:25 -0400
Received: by mail-pg0-f54.google.com with SMTP id m9so1540616pgd.3
        for <netdev@vger.kernel.org>; Thu, 07 Sep 2017 14:20:24 -0700 (PDT)
In-Reply-To: <3B91CCFCFC433E4596591DB9A191998574453125@nkgeml514-mbx.china.huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 7, 2017 at 3:18 AM, Songchuan <songchuan@huawei.com> wrote:
> <4>[ 1730.085113s][pid:1928,cpu3,HeapTaskDaemon]CPU: 3 PID: 1928 Comm: HeapTaskDaemon Tainted: G    B   W       4.1.18-kasan-g6e99722-dirty #1

Sorry, 4.1 is too old for upstream. As you know 4.13 is just out.
Please try to reproduce it on the latest or reasonably recent kernel.
