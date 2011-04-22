From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] bonding: fix bridged bonds in 802.3ad mode
Date: Fri, 22 Apr 2011 08:27:03 -0700
Message-ID: <20110422082703.6f81f03f@nehalam>
References: <20110421184748.GD23756@midget.suse.cz>
	<1303412899.3165.47.camel@bwh-desktop>
	<4DB096E0.4010407@polymtl.ca>
	<20110421.211935.226766915.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: benjamin.poirier@polymtl.ca, bhutchings@solarflare.com,
	jbohac@suse.cz, netdev@vger.kernel.org, fubar@us.ibm.com,
	andy@greyhouse.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:36975 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752204Ab1DVP1G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Apr 2011 11:27:06 -0400
In-Reply-To: <20110421.211935.226766915.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 21 Apr 2011 21:19:35 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Benjamin Poirier <benjamin.poirier@polymtl.ca>
> Date: Thu, 21 Apr 2011 16:43:12 -0400
> 
> > On 21/04/11 03:08 PM, Ben Hutchings wrote:
> >> It seems to me that 1e253c3b8a1aeed51eef6fc366812f219b97de65 is bogus
> > 
> > You bet, it's rubbish ;)
> 
> I've reverted it from net-2.6 and will send the revert to -stable
> too.
> 
> Thanks.

Acked-by: Stephen Hemminger <shemminger@vyatta.com>


-- 
