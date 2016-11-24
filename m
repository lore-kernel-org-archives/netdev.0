From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [patch] net/mlx5: remove a duplicate condition
Date: Thu, 24 Nov 2016 17:30:00 +0200
Message-ID: <CALzJLG97UUXQi6qYOqm_EePkv-k5JxyVxN_he1QZrJx2Yui2Tg@mail.gmail.com>
References: <20161124110345.GC17225@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Saeed Mahameed <saeedm@mellanox.com>,
        Matan Barak <matanb@mellanox.com>,
        Leon Romanovsky <leonro@mellanox.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        linux-rdma@vger.kernel.org,
        linux-kernel <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f52.google.com ([209.85.215.52]:32871 "EHLO
        mail-lf0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S966765AbcKXPhi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2016 10:37:38 -0500
Received: by mail-lf0-f52.google.com with SMTP id c13so31385634lfg.0
        for <netdev@vger.kernel.org>; Thu, 24 Nov 2016 07:37:29 -0800 (PST)
In-Reply-To: <20161124110345.GC17225@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 24, 2016 at 1:03 PM, Dan Carpenter <dan.carpenter@oracle.com> wrote:
> We verified that MLX5_FLOW_CONTEXT_ACTION_COUNT was set on the first
> line of the function so we don't need to check again here.
>
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Acked-by: Saeed Mahameed <saeedm@mellanox.com>
