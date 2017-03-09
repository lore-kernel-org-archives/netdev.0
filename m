From: Tariq Toukan <tariqt@mellanox.com>
Subject: Re: [PATCH v4 net-next 02/13] mlx4: remove order field from
 mlx4_en_frag_info
Date: Thu, 9 Mar 2017 15:53:31 +0200
Message-ID: <c4e58408-d821-523e-e267-c6ee39d1069b@mellanox.com>
References: <20170308161718.2867-1-edumazet@google.com>
 <20170308161718.2867-3-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Willem de Bruijn <willemb@google.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Alexei Starovoitov <ast@kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: Eric Dumazet <edumazet@google.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr20064.outbound.protection.outlook.com ([40.107.2.64]:43936
        "EHLO EUR02-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753690AbdCINyW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 9 Mar 2017 08:54:22 -0500
In-Reply-To: <20170308161718.2867-3-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 08/03/2017 6:17 PM, Eric Dumazet wrote:
> This is really a port attribute, no need to duplicate it per
> RX queue and per frag.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
>  drivers/net/ethernet/mellanox/mlx4/en_rx.c   | 6 +++---
>  drivers/net/ethernet/mellanox/mlx4/mlx4_en.h | 2 +-
>  2 files changed, 4 insertions(+), 4 deletions(-)
>
Acked-by: Tariq Toukan <tariqt@mellanox.com>

Thanks.
