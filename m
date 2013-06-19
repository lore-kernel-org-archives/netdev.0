From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next V1 1/2] net/mlx4_en: Add Low Latency Socket
 (LLS) support
Date: Wed, 19 Jun 2013 01:21:50 -0700
Message-ID: <1371630110.3252.270.camel@edumazet-glaptop>
References: <1371561508-11960-1-git-send-email-amirv@mellanox.com>
	 <1371561508-11960-2-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eliezer Tamir <eliezer.tamir@linux.intel.com>,
	Eric Dumazet <edumazet@google.com>
To: Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f173.google.com ([209.85.215.173]:50996 "EHLO
	mail-ea0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756551Ab3FSIVz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jun 2013 04:21:55 -0400
Received: by mail-ea0-f173.google.com with SMTP id g15so3082745eak.18
        for <netdev@vger.kernel.org>; Wed, 19 Jun 2013 01:21:54 -0700 (PDT)
In-Reply-To: <1371561508-11960-2-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-06-18 at 16:18 +0300, Amir Vadai wrote:
> Add basic support for LLS.
> 
> Signed-off-by: Amir Vadai <amirv@mellanox.com>
> ---
>  drivers/net/ethernet/mellanox/mlx4/en_cq.c     |   3 +
>  drivers/net/ethernet/mellanox/mlx4/en_netdev.c |  43 ++++++++-
>  drivers/net/ethernet/mellanox/mlx4/en_rx.c     |  15 ++-
>  drivers/net/ethernet/mellanox/mlx4/mlx4_en.h   | 121 +++++++++++++++++++++++++
>  4 files changed, 178 insertions(+), 4 deletions(-)

Reviewed-by: Eric Dumazet <edumazet@google.com>
