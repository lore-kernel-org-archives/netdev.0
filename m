From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH v2 net-next] net/mlx5e: remove napi_hash_del() calls
Date: Wed, 16 Nov 2016 16:34:51 +0200
Message-ID: <CALzJLG8EWsWsqT-XW8EL6MhWpuS=BhcZ6tbWd2cQEYYgHepfMw@mail.gmail.com>
References: <1479304537.8455.167.camel@edumazet-glaptop3.roam.corp.google.com> <1479306094.8455.181.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Saeed Mahameed <saeedm@mellanox.com>,
        netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f171.google.com ([209.85.216.171]:34168 "EHLO
        mail-qt0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753144AbcKPOfM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 09:35:12 -0500
Received: by mail-qt0-f171.google.com with SMTP id n6so103541632qtd.1
        for <netdev@vger.kernel.org>; Wed, 16 Nov 2016 06:35:12 -0800 (PST)
In-Reply-To: <1479306094.8455.181.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 16, 2016 at 4:21 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> Calling napi_hash_del() after netif_napi_del() is pointless.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Saeed Mahameed <saeedm@mellanox.com>

Acked-by: Saeed Mahameed <saeedm@mellanox.com>
