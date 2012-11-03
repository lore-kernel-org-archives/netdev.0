From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/3] eth: Make is_link_local() consistent with
 other address tests
Date: Fri, 02 Nov 2012 21:34:42 -0400 (EDT)
Message-ID: <20121102.213442.1693331096254999175.davem@davemloft.net>
References: <1351797071.2883.13.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.r.fastabend@intel.com,
	shemminger@vyatta.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49295 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757380Ab2KCBes (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Nov 2012 21:34:48 -0400
In-Reply-To: <1351797071.2883.13.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 1 Nov 2012 19:11:11 +0000

> Function name should include '_ether_addr'.
> Return type should be bool.
> Parameter name should be 'addr' not 'dest' (also matching kernel-doc).
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
