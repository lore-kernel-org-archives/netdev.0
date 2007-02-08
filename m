From: =?ISO-8859-1?Q?Tobias_Ringstr=F6m?= <tobias@ringis.se>
Subject: Re: [PATCH] MAINTAINERS: update DMFE and wireless drivers mailing
 list
Date: Thu, 08 Feb 2007 10:08:53 +0100
Message-ID: <45CAE8A5.9070703@ringis.se>
References: <20070207155236.72f0b18c.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, linville@tuxdriver.com,
	tori@unhappy.mine.nu, jgarzik <jgarzik@pobox.com>,
	davem@davemloft.net, akpm <akpm@osdl.org>
To: Randy Dunlap <randy.dunlap@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw.swedot.se ([194.17.162.101]:52661 "EHLO mailgw.swedot.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965721AbXBHJdg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Feb 2007 04:33:36 -0500
In-Reply-To: <20070207155236.72f0b18c.randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Randy Dunlap wrote:
> From: Randy Dunlap <randy.dunlap@oracle.com>
>
> List netdev as the mailing list for DMFE (network driver)
> instead of lkml.
>
> List linux-wireless as the mailing list for wireless network drivers.
>
> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
> ---
>  MAINTAINERS |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>
> --- linux-2620-work.orig/MAINTAINERS
> +++ linux-2620-work/MAINTAINERS
> @@ -1096,7 +1096,7 @@ S:	Supported
>  DAVICOM FAST ETHERNET (DMFE) NETWORK DRIVER
>  P:	Tobias Ringstrom
>  M:	tori@unhappy.mine.nu
>   
While editing that section, would you please remove me (Tobias 
Ringstrom, tori@unhappy.mine.nu) from the dmfe driver in the MAINTAINERS 
file. I've not followed development for ages.

Thanks!

/Tobias

