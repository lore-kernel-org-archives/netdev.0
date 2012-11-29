From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next 1/3] MAINTAINERS: Add Mellanox ethernet driver
 - mlx4_en
Date: Thu, 29 Nov 2012 09:29:44 -0800
Message-ID: <1354210184.9874.8.camel@joe-AO722>
References: <1354194894-16527-1-git-send-email-amirv@mellanox.com>
	 <1354209333-27672-1-git-send-email-amirv@mellanox.com>
	 <1354209333-27672-2-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Oren Duer <oren@mellanox.com>, netdev@vger.kernel.org,
	Yevgeny Petrilin <yevgenyp@mellanox.com>
To: Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:45133 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751465Ab2K2R3o (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Nov 2012 12:29:44 -0500
In-Reply-To: <1354209333-27672-2-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-11-29 at 19:15 +0200, Amir Vadai wrote:
> Set mlx4_en maintainer to Amir Vadai instead of Yevgeny Petrilin.
> 
> Signed-off-by: Amir Vadai <amirv@mellanox.com>
> Cc: Yevgeny Petrilin <yevgenyp@mellanox.com>
> ---
>  MAINTAINERS |    7 +++++++
>  1 files changed, 7 insertions(+), 0 deletions(-)
> 
> diff --git a/MAINTAINERS b/MAINTAINERS
> index 5d72dd5..67fd3de 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -4822,6 +4822,13 @@ F:	Documentation/scsi/megaraid.txt
>  F:	drivers/scsi/megaraid.*
>  F:	drivers/scsi/megaraid/
>  
> +MELLANOX ETHERNET DRIVER (mlx4_en)
> +M:	Amir Vadai <amirv@mellanox.com>
> +L: 	netdev@vger.kernel.org
> +S:	Supported
> +W:	http://www.mellanox.com
> +Q:	http://patchwork.ozlabs.org/project/netdev/list/

What about a file pattern?  Maybe
F:	drivers/net/ethernet/mellanox/mlx/
