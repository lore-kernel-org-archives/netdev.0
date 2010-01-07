From: Dominik Brodowski <linux@dominikbrodowski.net>
Subject: Re: [PATCH 02/15] pcmcia: remove remaining unused IRQ_FIRST_SHARED
 parameter
Date: Thu, 7 Jan 2010 09:20:09 +0100
Message-ID: <20100107082009.GA3361@dominikbrodowski.net>
References: <20100106114531.GA29913@comet.dominikbrodowski.net>
 <1262778386-30182-2-git-send-email-linux@dominikbrodowski.net>
 <20100106.202332.241912228.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-pcmcia@lists.infradead.org, netdev@vger.kernel.org,
	komurojun-mbn@nifty.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from isilmar.linta.de ([213.133.102.198]:36376 "EHLO linta.de"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755343Ab0AGI1p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Jan 2010 03:27:45 -0500
Content-Disposition: inline
In-Reply-To: <20100106.202332.241912228.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hey,

On Wed, Jan 06, 2010 at 08:23:32PM -0800, David Miller wrote:
> From: Dominik Brodowski <linux@dominikbrodowski.net>
> Date: Wed,  6 Jan 2010 12:46:13 +0100
> 
> > Komuro pointed out correctly that I missed one IRQ_FIRST_SHARED
> > parameter in smc91c92_cs.c, and that another line could be writter
> > more beautifully.
> > 
> > CC: netdev@vger.kernel.org
> > CC: Komuro <komurojun-mbn@nifty.com>
> > Signed-off-by: Dominik Brodowski <linux@dominikbrodowski.net>
> 
> Please can the pcmcia tree person integrate this one?

That's the plan, thanks.

Best,
	Dominik
