From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net-next] tcp: remove in_flight parameter from
 cong_avoid() methods
Date: Sat, 3 May 2014 07:37:59 -0400
Message-ID: <CADVnQynLQw=_78BmGRNGy4Gg0wc5GLZ12vfcaVTSM1k+f-Yp4w@mail.gmail.com>
References: <1399090685.2140.12.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f46.google.com ([74.125.82.46]:45968 "EHLO
	mail-wg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751131AbaECLiB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 May 2014 07:38:01 -0400
Received: by mail-wg0-f46.google.com with SMTP id n12so3607594wgh.17
        for <netdev@vger.kernel.org>; Sat, 03 May 2014 04:37:59 -0700 (PDT)
In-Reply-To: <1399090685.2140.12.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 3, 2014 at 12:18 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> Commit e114a710aa505 ("tcp: fix cwnd limited checking to improve
> congestion control") obsoleted in_flight parameter from
> tcp_is_cwnd_limited() and its callers.
>
> This patch does the removal as promised.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---

Acked-by: Neal Cardwell <ncardwell@google.com>

Thanks, Eric!

neal
