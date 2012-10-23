From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net-next] ipv4: tcp: clean up tcp_v4_early_demux()
Date: Tue, 23 Oct 2012 08:59:35 -0400
Message-ID: <CADVnQynW+yObdHVWkSbuvjb0n6pCYcL4TPtuoWayHTb69oPD0g@mail.gmail.com>
References: <1350978167.8609.1545.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f174.google.com ([209.85.216.174]:54590 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753399Ab2JWM7g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2012 08:59:36 -0400
Received: by mail-qc0-f174.google.com with SMTP id o22so2133632qcr.19
        for <netdev@vger.kernel.org>; Tue, 23 Oct 2012 05:59:36 -0700 (PDT)
In-Reply-To: <1350978167.8609.1545.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 23, 2012 at 3:42 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> Use same header helpers than tcp_v6_early_demux() because they
> are a bit faster, and as they make IPv4/IPv6 versions look
> the same.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Neal Cardwell <ncardwell@google.com>
> ---

Acked-by: Neal Cardwell <ncardwell@google.com>

Thanks, Eric!

neal
