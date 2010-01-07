From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 02/15] pcmcia: remove remaining unused IRQ_FIRST_SHARED
 parameter
Date: Wed, 06 Jan 2010 20:23:32 -0800 (PST)
Message-ID: <20100106.202332.241912228.davem@davemloft.net>
References: <20100106114531.GA29913@comet.dominikbrodowski.net>
	<1262778386-30182-2-git-send-email-linux@dominikbrodowski.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-pcmcia@lists.infradead.org, netdev@vger.kernel.org,
	komurojun-mbn@nifty.com
To: linux@dominikbrodowski.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47133
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932124Ab0AGEXX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2010 23:23:23 -0500
In-Reply-To: <1262778386-30182-2-git-send-email-linux@dominikbrodowski.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dominik Brodowski <linux@dominikbrodowski.net>
Date: Wed,  6 Jan 2010 12:46:13 +0100

> Komuro pointed out correctly that I missed one IRQ_FIRST_SHARED
> parameter in smc91c92_cs.c, and that another line could be writter
> more beautifully.
> 
> CC: netdev@vger.kernel.org
> CC: Komuro <komurojun-mbn@nifty.com>
> Signed-off-by: Dominik Brodowski <linux@dominikbrodowski.net>

Please can the pcmcia tree person integrate this one?

Thanks!

