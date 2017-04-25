From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net-next 04/10] tcp: do not pass timestamp to tcp_rack_identify_loss()
Date: Tue, 25 Apr 2017 13:52:20 -0400
Message-ID: <CADVnQy=8BH5eCbsLiHXnFxAW2xXmsQ=4XVPkvj6iYzbZB=z4aA@mail.gmail.com>
References: <20170425171541.3417-1-edumazet@google.com> <20170425171541.3417-5-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f51.google.com ([209.85.218.51]:35761 "EHLO
        mail-oi0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1432549AbdDYRwv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 13:52:51 -0400
Received: by mail-oi0-f51.google.com with SMTP id j201so180933221oih.2
        for <netdev@vger.kernel.org>; Tue, 25 Apr 2017 10:52:51 -0700 (PDT)
In-Reply-To: <20170425171541.3417-5-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 25, 2017 at 1:15 PM, Eric Dumazet <edumazet@google.com> wrote:
> Not used anymore now tp->tcp_mstamp holds the information.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Acked-by: Soheil Hassas Yeganeh <soheil@google.com>

Acked-by: Neal Cardwell <ncardwell@google.com>

neal
