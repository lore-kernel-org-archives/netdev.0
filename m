From: Amir Vadai <amirv@mellanox.com>
Subject: Re: [PATCH net-next] mellanox: Change en_print to return void
Date: Tue, 23 Sep 2014 08:45:54 +0300
Message-ID: <54210912.1000203@mellanox.com>
References: <1411407622.2952.49.camel@joe-AO725>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog117.obsmtp.com ([207.126.144.143]:50057 "EHLO
	eu1sys200aog117.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751730AbaIWFva (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2014 01:51:30 -0400
In-Reply-To: <1411407622.2952.49.camel@joe-AO725>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/22/2014 8:40 PM, Joe Perches wrote:
> No caller or macro uses the return value so make it void.
> 
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
> This change is associated to a desire to eventually
> change printk to return void.
> 
>  drivers/net/ethernet/mellanox/mlx4/en_main.c | 17 +++++++----------
>  drivers/net/ethernet/mellanox/mlx4/mlx4_en.h |  4 ++--
>  2 files changed, 9 insertions(+), 12 deletions(-)

Thanks Joe.

Acked-By: Amir Vadai <amirv@mellanox.com>
