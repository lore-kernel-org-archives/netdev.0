From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v2 00/16] mlx4_en: driver updates
Date: Wed, 23 Mar 2011 19:34:15 +0000
Message-ID: <1300908855.2638.16.camel@bwh-desktop>
References: <4D89B13B.2010404@mellanox.co.il>
	 <20110323.122612.229763242.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: yevgenyp@mellanox.co.il, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:47760 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756629Ab1CWTeS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Mar 2011 15:34:18 -0400
In-Reply-To: <20110323.122612.229763242.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-03-23 at 12:26 -0700, David Miller wrote:
> From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
> Date: Wed, 23 Mar 2011 10:37:15 +0200
> 
> > Hello David,
> > 
> > This is the second round for patches originally sent on March 07.
> > 
> > Changes from previous round (after getting the feedbacks):
> > 1. Renamed IRQ name for TX rings.
> > 2. Changed error message when failing to map BlueFlame area.
> > 3. Removed drivers/infiniband/hw/mlx4/ parts of steering changes, those need to be applied with Raw QP support.
> 
> Series applied to net-2.6, thanks.

Including 08/16 'mlx4_en: Reporting HW revision in ethtool -i'?

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

