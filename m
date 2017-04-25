From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net-next 09/10] tcp: remove ack_time from struct tcp_sacktag_state
Date: Tue, 25 Apr 2017 13:53:50 -0400
Message-ID: <CADVnQykTOcHt_-VQvVHz9s5Edrzd_hBxA8HEznwLczRqFeGTGA@mail.gmail.com>
References: <20170425171541.3417-1-edumazet@google.com> <20170425171541.3417-10-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f49.google.com ([209.85.218.49]:36502 "EHLO
        mail-oi0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1946684AbdDYRyV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 13:54:21 -0400
Received: by mail-oi0-f49.google.com with SMTP id w12so69025215oiw.3
        for <netdev@vger.kernel.org>; Tue, 25 Apr 2017 10:54:21 -0700 (PDT)
In-Reply-To: <20170425171541.3417-10-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 25, 2017 at 1:15 PM, Eric Dumazet <edumazet@google.com> wrote:
> It is no longer needed, everything uses tp->tcp_mstamp instead.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Acked-by: Soheil Hassas Yeganeh <soheil@google.com>

Acked-by: Neal Cardwell <ncardwell@google.com>

neal
