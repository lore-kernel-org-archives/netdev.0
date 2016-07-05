From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH] net/mlx5: Avoid setting unused var when modifying vport
 node GUID
Date: Tue, 5 Jul 2016 12:59:22 +0300
Message-ID: <CALzJLG83YrEJnxC8e-4hU37WtjGz-W28OkbdiayXX5zHqC_qUg@mail.gmail.com>
References: <1467710232-31192-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Noa Osherovich <noaos@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f175.google.com ([209.85.161.175]:32919 "EHLO
	mail-yw0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754641AbcGEJ7m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2016 05:59:42 -0400
Received: by mail-yw0-f175.google.com with SMTP id v77so57242990ywg.0
        for <netdev@vger.kernel.org>; Tue, 05 Jul 2016 02:59:42 -0700 (PDT)
In-Reply-To: <1467710232-31192-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 5, 2016 at 12:17 PM, Or Gerlitz <ogerlitz@mellanox.com> wrote:
> GCC complains on unused-but-set-variable, clean this up.
>
> Fixes: 23898c763f4a ('net/mlx5: E-Switch, Modify node guid on vf set MAC')
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>

Acked-by: Saeed Mahameed <saeedm@mellanox.com>
