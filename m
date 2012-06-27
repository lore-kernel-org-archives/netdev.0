From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv1] net: added support for 40GbE link.
Date: Wed, 27 Jun 2012 15:42:36 -0700 (PDT)
Message-ID: <20120627.154236.2191644759533537024.davem@davemloft.net>
References: <054018eb-a85c-4401-a010-7479aa38d2ef@exht1.ad.emulex.com>
	<1340812980.2591.0.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: parav.pandit@emulex.com, netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47785 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755583Ab2F0Wmh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2012 18:42:37 -0400
In-Reply-To: <1340812980.2591.0.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 27 Jun 2012 17:03:00 +0100

> On Wed, 2012-06-27 at 19:26 +0530, Parav Pandit wrote:
>> 1. removed code replication for tov calculation for 1G, 10G and
>> made is common for speed > 1G (1G, 10G, 40G, 100G).
>> 2. defines values for #4 different 40G Phys (KR4, LF4, SR4, CR4)
>> 
>> Signed-off-by: Parav Pandit <parav.pandit@emulex.com>
> Reviewed-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
