From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] sfc: Don't specify unexistent IRQ
Date: Wed, 08 Apr 2009 16:00:02 -0700 (PDT)
Message-ID: <20090408.160002.119907202.davem@davemloft.net>
References: <20090408023819.GA14188@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	khali@linux-fr.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46001
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755720AbZDHXAM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2009 19:00:12 -0400
In-Reply-To: <20090408023819.GA14188@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 8 Apr 2009 03:38:20 +0100

> Neither the lm90 driver nor the lm87 driver do support interrupts, so
> there is no point in specifying one when declaring the devices.
> 
> Signed-off-by: Jean Delvare <khali@linux-fr.org>
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied, thanks.
