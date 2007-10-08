From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] [343/2many] MAINTAINERS - IPVS
Date: Mon, 8 Oct 2007 10:43:37 +1000
Message-ID: <20071008004333.GF2497@verge.net.au>
References: <46bffb10.JY5EkYQg+QBB0ZZx%joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: wensong@linux-vs.org, torvalds@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org, ja@ssi.bg,
	akpm@linux-foundation.org
To: joe@perches.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758150AbXJHAoS@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <46bffb10.JY5EkYQg+QBB0ZZx%joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Aug 12, 2007 at 11:32:48PM -0700, joe@perches.com wrote:
> Add file pattern to MAINTAINER entry
> 
> Signed-off-by: Joe Perches <joe@perches.com>
> 
> diff --git a/MAINTAINERS b/MAINTAINERS
> index dbfdb75..a8fb231 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -3300,6 +3300,8 @@ P:	Julian Anastasov
>  M:	ja@ssi.bg
>  L:	netdev@vger.kernel.org
>  S:	Maintained
> +F:	Documentation/networking/ipvs-sysctl.txt
> +F:	net/ipv4/ipvs

Should the following also be added:?

+F: include/net/ip_vs.h

>  
>  NFS CLIENT
>  P:	Trond Myklebust
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/
