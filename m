From: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH 12/15] net: sunrpc: removed duplicated #include
Date: Thu, 5 Aug 2010 11:09:20 -0400
Message-ID: <20100805150920.GB27141@fieldses.org>
References: <1281016299-23958-1-git-send-email-andrea.gelmini@gelma.net>
 <1281016299-23958-12-git-send-email-andrea.gelmini@gelma.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: gelma-PT7Us6ch6G9eoWH0uzbU5w@public.gmane.org, Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	Neil Brown <neilb-l3A5Bk7waGM@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Andrea Gelmini <andrea.gelmini-PT7Us6ch6G9eoWH0uzbU5w@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1281016299-23958-12-git-send-email-andrea.gelmini-PT7Us6ch6G9eoWH0uzbU5w@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 05, 2010 at 03:51:36PM +0200, Andrea Gelmini wrote:
> Signed-off-by: Andrea Gelmini <andrea.gelmini-PT7Us6ch6G9eoWH0uzbU5w@public.gmane.org>

Thanks, applied for 2.6.36.

--b.

> ---
>  net/sunrpc/cache.c |    1 -
>  1 files changed, 0 insertions(+), 1 deletions(-)
> 
> diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
> index 58de76c..b75879b 100644
> --- a/net/sunrpc/cache.c
> +++ b/net/sunrpc/cache.c
> @@ -34,7 +34,6 @@
>  #include <linux/sunrpc/cache.h>
>  #include <linux/sunrpc/stats.h>
>  #include <linux/sunrpc/rpc_pipe_fs.h>
> -#include <linux/smp_lock.h>
>  
>  #define	 RPCDBG_FACILITY RPCDBG_CACHE
>  
> -- 
> 1.7.2.1.85.g2d089
> 
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
