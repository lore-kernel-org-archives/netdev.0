From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] tc: comment spelling fixes
Date: Mon, 21 Nov 2011 17:12:08 +0000
Message-ID: <1321895528.2692.4.camel@bwh-desktop>
References: <20111121085346.2203c4f4@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:43446 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751623Ab1KURMM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2011 12:12:12 -0500
In-Reply-To: <20111121085346.2203c4f4@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-11-21 at 08:53 -0800, Stephen Hemminger wrote:
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> --- a/include/linux/pkt_sched.h	2011-11-09 13:54:59.780009551 -0800
> +++ b/include/linux/pkt_sched.h	2011-11-21 08:51:20.062228855 -0800
> @@ -30,7 +30,7 @@
>   */
>  
>  struct tc_stats {
> -	__u64	bytes;			/* NUmber of enqueues bytes */
> +	__u64	bytes;			/* Number of enqueues bytes */
[...]

Further fix needed: 'enqueued'.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
