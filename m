From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: use sock_valbool_flag to set/clear SOCK_RXQ_OVFL
Date: Fri, 07 Oct 2011 13:27:23 -0400 (EDT)
Message-ID: <20111007.132723.357609143565568448.davem@davemloft.net>
References: <1317994221.3988.12.camel@jlt3.sipsolutions.net>
	<20111007134023.GC11408@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johannes@sipsolutions.net, netdev@vger.kernel.org
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41607 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751487Ab1JGR3d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Oct 2011 13:29:33 -0400
In-Reply-To: <20111007134023.GC11408@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Fri, 7 Oct 2011 09:40:23 -0400

> On Fri, Oct 07, 2011 at 03:30:20PM +0200, Johannes Berg wrote:
>> From: Johannes Berg <johannes.berg@intel.com>
>> 
>> There's no point in open-coding sock_valbool_flag().
>> 
>> Signed-off-by: Johannes Berg <johannes.berg@intel.com>
 ...
> Looks good, thanks Johannes!
> Acked-by: Neil Horman <nhorman@tuxdriver.com>

Applied to net-next, thanks.
