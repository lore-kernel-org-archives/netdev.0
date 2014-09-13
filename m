From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] netdevice: Support DSA tagging when DSA is built as
 a module
Date: Sat, 13 Sep 2014 17:37:27 -0400 (EDT)
Message-ID: <20140913.173727.1154743873985384844.davem@davemloft.net>
References: <20140913061142.28675.38168.stgit@ahduyck-workstation.home>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com, kernel@wantstofly.org
To: alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38370 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752087AbaIMVh3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Sep 2014 17:37:29 -0400
In-Reply-To: <20140913061142.28675.38168.stgit@ahduyck-workstation.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: alexander.duyck@gmail.com
Date: Fri, 12 Sep 2014 23:12:46 -0700

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> This change corrects an error seen when DSA tagging is built as a module.
> Without this change it is not possible to get XDSA tagged frames as the
> test for tagging is stripped by the #ifdef check.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Acked-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
> 
> v2: Just working out some kinks in my stgit config so that this patch is
>     attributed to my intel.com address instead of my gmail.com address.

Applied, thanks.
