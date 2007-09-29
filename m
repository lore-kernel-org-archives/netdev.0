From: Paul Mundt <lethal@linux-sh.org>
Subject: Re: [PATCH] smc911x irq sense request and MPR2 board support
Date: Sat, 29 Sep 2007 15:33:10 +0900
Message-ID: <20070929063310.GA1395@linux-sh.org>
References: <200708200836.51182.super.firetwister@gmail.com> <46FDE19F.9000902@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Markus Brunner <super.firetwister@googlemail.com>,
	netdev@vger.kernel.org, Mark Jonas <toertel@gmail.com>
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ocgnet.org ([64.20.243.3]:49741 "EHLO smtp.ocgnet.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751965AbXI2Gdc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Sep 2007 02:33:32 -0400
Content-Disposition: inline
In-Reply-To: <46FDE19F.9000902@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Sep 29, 2007 at 01:24:47AM -0400, Jeff Garzik wrote:
> Markus Brunner wrote:
> >this are the changes to the smc911x driver, which were necessary
> >to get it running on the Magic Panel R2 (smsc9115).
> >It is a SH3-DSP based board. The other patches are available on 
> >the linuxsh-dev mailinglist.
> >http://marc.info/?l=linuxsh-dev&r=1&b=200708&w=2
> >
> >It was necessary to set the irq sense to low level.
> >Therefor the SMC_IRQ_SENSE define was added.
> >How are the chances for inclusion in 2.6.24?
> >
> >Signed-off by: Markus Brunner <super.firetwister@gmail.com>
> >Signed-off by: Mark Jonas <toertel@gmail.com>
> 
> does the SuperH maintainer ACK this?

Yes, this looks fine.

Acked-by: Paul Mundt <lethal@linux-sh.org>
