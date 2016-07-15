From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2-master 1/2] man: Add devlink man pages to
 Makefile
Date: Fri, 15 Jul 2016 11:47:39 -0700
Message-ID: <20160715114739.5f6fa627@xeon-e3>
References: <1468392834-5096-1-git-send-email-idosch@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <jiri@mellanox.com>,
	<eladr@mellanox.com>, <yotamg@mellanox.com>, <nogahf@mellanox.com>,
	<ogerlitz@mellanox.com>
To: Ido Schimmel <idosch@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:35700 "EHLO
	mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751322AbcGOSrX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2016 14:47:23 -0400
Received: by mail-pf0-f173.google.com with SMTP id c2so43902913pfa.2
        for <netdev@vger.kernel.org>; Fri, 15 Jul 2016 11:47:23 -0700 (PDT)
In-Reply-To: <1468392834-5096-1-git-send-email-idosch@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 13 Jul 2016 09:53:53 +0300
Ido Schimmel <idosch@mellanox.com> wrote:

> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> ---
>  man/man8/Makefile | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/man/man8/Makefile b/man/man8/Makefile
> index 929826e..9badbed 100644
> --- a/man/man8/Makefile
> +++ b/man/man8/Makefile
> @@ -16,7 +16,8 @@ MAN8PAGES = $(TARGETS) ip.8 arpd.8 lnstat.8 routel.8 rtacct.8 rtmon.8 rtpr.8 ss.
>  	tc-basic.8 tc-cgroup.8 tc-flow.8 tc-flower.8 tc-fw.8 tc-route.8 \
>  	tc-tcindex.8 tc-u32.8 \
>  	tc-connmark.8 tc-csum.8 tc-mirred.8 tc-nat.8 tc-pedit.8 tc-police.8 \
> -	tc-simple.8 tc-skbedit.8 tc-vlan.8 tc-xt.8
> +	tc-simple.8 tc-skbedit.8 tc-vlan.8 tc-xt.8 \
> +	devlink.8 devlink-dev.8 devlink-monitor.8 devlink-port.8 devlink-sb.8
>  
>  all: $(TARGETS)
>  

Both applied thanks
