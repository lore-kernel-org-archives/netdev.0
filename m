From: KOVACS Krisztian <hidden@sch.bme.hu>
Subject: Re: [PATCH 6/6]: [CASSINI]: Bump driver version and release date.
Date: Fri, 4 Jan 2008 11:25:08 +0100
Message-ID: <20080104102507.GA31476@sch.bme.hu>
References: <20080104.003512.18469292.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, panther@balabit.hu, bazsi@balabit.hu,
	hidden@sch.bme.hu
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from centaur.sch.bme.hu ([152.66.208.5]:48656 "EHLO
	centaur.sch.bme.hu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751049AbYADKZK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jan 2008 05:25:10 -0500
Content-Disposition: inline
In-Reply-To: <20080104.003512.18469292.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On p, jan 04, 2008 at 12:35:12 -0800, David Miller wrote:
> [CASSINI]: Bump driver version and release date.
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>  drivers/net/cassini.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/cassini.c b/drivers/net/cassini.c
> index c3220e4..3a9bb17 100644
> --- a/drivers/net/cassini.c
> +++ b/drivers/net/cassini.c
> @@ -142,8 +142,8 @@
>  
>  #define DRV_MODULE_NAME		"cassini"
>  #define PFX DRV_MODULE_NAME	": "
> -#define DRV_MODULE_VERSION	"1.4"
> -#define DRV_MODULE_RELDATE	"1 July 2004"
> +#define DRV_MODULE_VERSION	"1.5"
> +#define DRV_MODULE_RELDATE	"4 Jan 2007"

Erm, 2008?

>  #define CAS_DEF_MSG_ENABLE	  \
>  	(NETIF_MSG_DRV		| \
> -- 
> 1.5.4.rc2.17.g257f
> 

-- 
KOVACS Krisztian
