From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bonding: fix bridged bonds in 802.3ad mode
Date: Thu, 21 Apr 2011 21:19:35 -0700 (PDT)
Message-ID: <20110421.211935.226766915.davem@davemloft.net>
References: <20110421184748.GD23756@midget.suse.cz>
	<1303412899.3165.47.camel@bwh-desktop>
	<4DB096E0.4010407@polymtl.ca>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, jbohac@suse.cz, netdev@vger.kernel.org,
	shemminger@linux-foundation.org, fubar@us.ibm.com,
	andy@greyhouse.net
To: benjamin.poirier@polymtl.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38215
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750730Ab1DVEUJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Apr 2011 00:20:09 -0400
In-Reply-To: <4DB096E0.4010407@polymtl.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benjamin Poirier <benjamin.poirier@polymtl.ca>
Date: Thu, 21 Apr 2011 16:43:12 -0400

> On 21/04/11 03:08 PM, Ben Hutchings wrote:
>> It seems to me that 1e253c3b8a1aeed51eef6fc366812f219b97de65 is bogus
> 
> You bet, it's rubbish ;)

I've reverted it from net-2.6 and will send the revert to -stable
too.

Thanks.
