From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net-next] tcp: do not fake tcp headers in tcp_send_rcvq()
Date: Wed, 17 Sep 2014 14:14:36 -0400
Message-ID: <CADVnQynSVpAQooO8G7KN6Ca4VnqVKXOJozE60PeY7dRB=PSt7A@mail.gmail.com>
References: <1410948882.7106.212.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Pavel Emelyanov <xemul@parallels.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f180.google.com ([209.85.214.180]:59782 "EHLO
	mail-ob0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756175AbaIQSOg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Sep 2014 14:14:36 -0400
Received: by mail-ob0-f180.google.com with SMTP id wp18so23889obc.25
        for <netdev@vger.kernel.org>; Wed, 17 Sep 2014 11:14:36 -0700 (PDT)
In-Reply-To: <1410948882.7106.212.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 17, 2014 at 6:14 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> Now we no longer rely on having tcp headers for skbs in receive queue,
> tcp repair do not need to build fake ones.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Acked-by: Neal Cardwell <ncardwell@google.com>

neal
