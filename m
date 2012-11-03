From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/3] bridge: Use is_link_local() in
 store_group_addr()
Date: Fri, 02 Nov 2012 21:34:36 -0400 (EDT)
Message-ID: <20121102.213436.1866522756298779775.davem@davemloft.net>
References: <1351797004.2883.12.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49285 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753285Ab2KCBei (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Nov 2012 21:34:38 -0400
In-Reply-To: <1351797004.2883.12.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 1 Nov 2012 19:10:04 +0000

> Parse the string into an array of bytes rather than ints, so we can
> use is_link_local() rather than reimplementing it.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
