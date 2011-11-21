From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xen-netback: use correct index for invalidation in
 xen_netbk_tx_check_gop()
Date: Mon, 21 Nov 2011 15:32:42 -0500 (EST)
Message-ID: <20111121.153242.32677392378823093.davem@davemloft.net>
References: <1321630925-13652-1-git-send-email-ian.campbell@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xen-devel@lists.xensource.com,
	JBeulich@suse.com, stable@vger.kernel.org
To: ian.campbell@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40630 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752502Ab1KUUcx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2011 15:32:53 -0500
In-Reply-To: <1321630925-13652-1-git-send-email-ian.campbell@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ian Campbell <ian.campbell@citrix.com>
Date: Fri, 18 Nov 2011 15:42:05 +0000

> From: Jan Beulich <JBeulich@suse.com>
> 
> Signed-off-by: Jan Beulich <jbeulich@suse.com>
> Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
> Cc: stable@vger.kernel.org

Applied, and I left the CC: in there so that it automatically gets picked up by
-stable.

Thanks.
