From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 0/3 net] xen-netback: fix ethtool stats and memory
 leak
Date: Thu, 05 Mar 2015 14:59:41 -0500 (EST)
Message-ID: <20150305.145941.533139747044848655.davem@davemloft.net>
References: <1425467688-12846-1-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xen-devel@lists.xenproject.org,
	ian.campbell@citrix.com, wei.liu2@citrix.com
To: david.vrabel@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60887 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753541AbbCET7n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2015 14:59:43 -0500
In-Reply-To: <1425467688-12846-1-git-send-email-david.vrabel@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Vrabel <david.vrabel@citrix.com>
Date: Wed, 4 Mar 2015 11:14:45 +0000

> A couple of bug fixes for netback:
> - make ethool stats to report the correct values.
> - don't leak 1 MiB every time a VIF is destroyed.
> 
> Changes in v2:
> - Split 2nd patch into leak fix and refactor patches

Series applied, thanks.
