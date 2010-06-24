From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next-2.6 5/5] sfc: Record hardware RX hash on each
 skb where possible
Date: Thu, 24 Jun 2010 16:18:28 +0100
Message-ID: <1277392708.2100.3.camel@achroite.uk.solarflarecom.com>
References: <1277328447.2101.7.camel@achroite.uk.solarflarecom.com>
	 <1277328688.2101.12.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:59921 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754149Ab0FXPSc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jun 2010 11:18:32 -0400
In-Reply-To: <1277328688.2101.12.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David,

Unfortunately, this version of the patch can hit a hardware bug that
results in bogus hashes.  Let me know whether you've applied it, and
I'll send an incremental or a replacement patch.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

