From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH net-next] Remove unnecessary driver assignments of
 ethtool_ringparam fields to zero
Date: Fri, 07 Oct 2011 19:13:41 -0400 (EDT)
Message-ID: <20111007.191341.833783740566988169.davem@davemloft.net>
References: <20111007224838.DCD05290054F@tardy>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com, mchan@broadcom.com,
	rmody@brocade.com, divy@chelsio.com, alexander.h.duyck@intel.com,
	jeffrey.t.kirsher@intel.com, buytenh@wantstofly.org,
	sony.chacko@qlogic.com, anirban.chakraborty@qlogic.com,
	bhutchings@solarflare.com
To: raj@tardy.cup.hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54012 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754028Ab1JGXQw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Oct 2011 19:16:52 -0400
In-Reply-To: <20111007224838.DCD05290054F@tardy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: raj@tardy.cup.hp.com (Rick Jones)
Date: Fri,  7 Oct 2011 15:48:38 -0700 (PDT)

> From: Rick Jones <rick.jones2@hp.com>
> 
> Per comments from Ben Hutchings on a previous patch, sweep the floors
> a little removing unnecessary assignments of zero to fields of struct
> ethtool_ringparam in driver code supporting ethtool -g.
> 
> Signed-off-by: Rick Jones <rick.jones2@hp.com>

I'm fine with this, applied.

Thanks.
