From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] bridge: correct print message typo
Date: Tue, 24 Oct 2006 22:49:09 -0700
Message-ID: <453EFAD5.60707@osdl.org>
References: <20061024212458.58a36232.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:43655 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1423018AbWJYFtu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2006 01:49:50 -0400
To: Randy Dunlap <randy.dunlap@oracle.com>
In-Reply-To: <20061024212458.58a36232.randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Randy Dunlap wrote:
> From: Randy Dunlap <randy.dunlap@oracle.com>
>
> Correct message typo/spello.
>
> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
> ---
>  net/bridge/br_sysfs_br.c |    2 +-
>  1 files changed, 1 insertion(+), 1 deletion(-)
>
> --- linux-2619-rc3-pv.orig/net/bridge/br_sysfs_br.c
> +++ linux-2619-rc3-pv/net/bridge/br_sysfs_br.c
> @@ -376,7 +376,7 @@ int br_sysfs_addbr(struct net_device *de
>  
>  	err = sysfs_create_bin_file(brobj, &bridge_forward);
>  	if (err) {
> -		pr_info("%s: can't create attribue file %s/%s\n",
> +		pr_info("%s: can't create attribute file %s/%s\n",
>  			__FUNCTION__, dev->name, bridge_forward.attr.name);
>  		goto out2;
>  	}
>
>
> ---
>   
no problemo.
