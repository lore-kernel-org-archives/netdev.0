From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 09/18] Clean up duplicate includes in drivers/net/
Date: Tue, 14 Aug 2007 01:34:25 -0400
Message-ID: <46C13EE1.6010506@garzik.org>
References: <200708102105.l7AL5Ko8008971@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jesper.juhl@gmail.com,
	linville@tuxdriver.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:56248 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933054AbXHNFe3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Aug 2007 01:34:29 -0400
In-Reply-To: <200708102105.l7AL5Ko8008971@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

akpm@linux-foundation.org wrote:
> From: Jesper Juhl <jesper.juhl@gmail.com>
> 
> This patch cleans up duplicate includes in
> 	 drivers/net/
> 
> Signed-off-by: Jesper Juhl <jesper.juhl@gmail.com>
> Acked-by: "John W. Linville" <linville@tuxdriver.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  drivers/net/atl1/atl1_main.c           |    1 -
>  drivers/net/bfin_mac.c                 |    5 -----
>  drivers/net/bonding/bond_sysfs.c       |    1 -
>  drivers/net/fs_enet/fs_enet-main.c     |    2 --
>  drivers/net/gianfar.h                  |    1 -
>  drivers/net/gianfar_ethtool.c          |    1 -
>  drivers/net/irda/kingsun-sir.c         |    1 -
>  drivers/net/irda/mcs7780.c             |    1 -
>  drivers/net/mipsnet.c                  |    1 -
>  drivers/net/netxen/netxen_nic_main.c   |    1 -
>  drivers/net/qla3xxx.c                  |    1 -
>  drivers/net/tsi108_eth.c               |    1 -
>  drivers/net/wireless/ipw2200.h         |    1 -
>  drivers/net/wireless/zd1211rw/zd_def.h |    1 -
>  14 files changed, 19 deletions(-)

applied


