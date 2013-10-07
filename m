From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net V1 1/2] net/mlx4_en: Rename name of mlx4_en_rx_alloc
 members
Date: Mon, 07 Oct 2013 06:44:37 -0700
Message-ID: <1381153477.12191.1.camel@edumazet-glaptop.roam.corp.google.com>
References: <1381145893-20930-1-git-send-email-amirv@mellanox.com>
	 <1381145893-20930-2-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	Eric Dumazet <edumazet@google.com>
To: Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:41323 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752153Ab3JGNol (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Oct 2013 09:44:41 -0400
Received: by mail-pd0-f178.google.com with SMTP id w10so7203713pde.9
        for <netdev@vger.kernel.org>; Mon, 07 Oct 2013 06:44:39 -0700 (PDT)
In-Reply-To: <1381145893-20930-2-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-10-07 at 13:38 +0200, Amir Vadai wrote:
> Add page prefix to page related members: @size and @offset into
> @page_size and @page_offset
> 
> CC: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Amir Vadai <amirv@mellanox.com>
> ---
>  drivers/net/ethernet/mellanox/mlx4/en_rx.c   | 40 ++++++++++++++++------------
>  drivers/net/ethernet/mellanox/mlx4/mlx4_en.h |  4 +--
>  2 files changed, 25 insertions(+), 19 deletions(-)

Acked-by: Eric Dumazet <edumazet@google.com>
