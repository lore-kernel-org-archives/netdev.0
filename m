From: David Miller <davem@davemloft.net>
Subject: Re: xen-netback: fix oopes during shutdown and error handling
Date: Thu, 14 Feb 2013 13:21:18 -0500 (EST)
Message-ID: <20130214.132118.1110984061087346493.davem@davemloft.net>
References: <1360847938-11185-1-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xen.org, konrad.wilk@oracle.com,
	ian.campbell@citrix.com, jbeulich@suse.com, wei.liu@citrix.com,
	netdev@vger.kernel.org
To: david.vrabel@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58617 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758431Ab3BNSVU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Feb 2013 13:21:20 -0500
In-Reply-To: <1360847938-11185-1-git-send-email-david.vrabel@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Vrabel <david.vrabel@citrix.com>
Date: Thu, 14 Feb 2013 13:18:56 +0000

> These two netback patches fix oopes that may occur during shutdown or
> if a specific fatal error occurs.
> 
> They are stable candidants.

Both applied and queued up for -stable, thanks.
