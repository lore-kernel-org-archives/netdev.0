From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next] net/sched: pkt_cls: change tc actions order to
 be as the user sets
Date: Mon, 26 Sep 2016 05:52:47 -0400
Message-ID: <d8c3b18a-367b-80c5-67ed-fbf6fad4cb21@mojatatu.com>
References: <1474812524-29089-1-git-send-email-hadarh@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Cong Wang <xiyou.wangcong@gmail.com>,
        Or Gerlitz <ogerlitz@mellanox.com>
To: Hadar Hen Zion <hadarh@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:36677 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751493AbcIZJwu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2016 05:52:50 -0400
Received: by mail-it0-f66.google.com with SMTP id n143so4582288ita.3
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 02:52:50 -0700 (PDT)
In-Reply-To: <1474812524-29089-1-git-send-email-hadarh@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-09-25 10:08 AM, Hadar Hen Zion wrote:
> Currently the created tc actions list is reversed against the order
> set by the user.
> Change the actions list order to be the same as was set by the user.
>
> Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>

Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal
