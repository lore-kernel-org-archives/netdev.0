From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net-next] tcp: do not export tcp_init_xmit_timers()
Date: Thu, 9 Jul 2015 12:13:26 -0400
Message-ID: <CADVnQy=wx2k8zC9GaHop7d7Vv1E3qMg_z+4J9fOW89x=ya3CmQ@mail.gmail.com>
References: <1436457700.24939.36.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f42.google.com ([209.85.218.42]:34321 "EHLO
	mail-oi0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752020AbbGIQN1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jul 2015 12:13:27 -0400
Received: by oiab3 with SMTP id b3so74535417oia.1
        for <netdev@vger.kernel.org>; Thu, 09 Jul 2015 09:13:27 -0700 (PDT)
In-Reply-To: <1436457700.24939.36.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 9, 2015 at 12:01 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> From: Eric Dumazet <edumazet@google.com>
>
> After commit 900f65d361d3 ("tcp: move duplicate code from
> tcp_v4_init_sock()/tcp_v6_init_sock()"), we no longer
> need to export tcp_init_xmit_timers()
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Neal Cardwell <ncardwell@google.com>

Acked-by: Neal Cardwell <ncardwell@google.com>

Thanks, Eric! Sorry for not noticing that earlier.

neal
