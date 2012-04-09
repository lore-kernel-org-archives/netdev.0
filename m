From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next] rtnetlink: fix spelling errors
Date: Mon, 9 Apr 2012 23:09:04 +0100
Message-ID: <1334009344.7150.268.camel@deadeye>
References: <20120409132756.32daeaa6@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:32710 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751565Ab2DIWJJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Apr 2012 18:09:09 -0400
In-Reply-To: <20120409132756.32daeaa6@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-04-09 at 13:27 -0700, Stephen Hemminger wrote:
> Minor spelling mistakes.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> --- a/include/net/rtnetlink.h	2012-02-27 08:43:02.400935781 -0800
> +++ b/include/net/rtnetlink.h	2012-04-09 13:24:02.705034830 -0700
> @@ -41,7 +41,7 @@ static inline int rtnl_msg_family(const
>   *	@get_size: Function to calculate required room for dumping device
>   *		   specific netlink attributes
>   *	@fill_info: Function to dump device specific netlink attributes
> - *	@get_xstats_size: Function to calculate required room for dumping devic
> + *	@get_xstats_size: Function to calculate required room for dumping device
>   *			  specific statistics
>   *	@fill_xstats: Function to dump device specific statistics
>   */
> @@ -94,7 +94,7 @@ extern void	rtnl_link_unregister(struct
>   * 	@fill_link_af: Function to fill IFLA_AF_SPEC with address family
>   * 		       specific netlink attributes.
>   * 	@get_link_af_size: Function to calculate size of address family specific
> - * 			   netlink attributes exlusive the container attribute.
> + * 			   netlink attributes exclusive the container attribute.
[...]

That's now a real word but it's not grammatically correct; 'exclusive
the' should be changed to 'exclusive of the' or 'excluding the'.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
