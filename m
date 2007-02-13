From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [TG3 2/8]: Use lower DMA watermark for 5703.
Date: Tue, 13 Feb 2007 14:42:44 -0500
Message-ID: <20070213194244.GA16991@havoc.gtf.org>
References: <1171397641.18944.26.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:46196 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750837AbXBMTmp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Feb 2007 14:42:45 -0500
Content-Disposition: inline
In-Reply-To: <1171397641.18944.26.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 13, 2007 at 12:14:01PM -0800, Michael Chan wrote:
> [TG3]: Use lower DMA watermark for 5703.
> 
> Set DMA read watermark to 4 on 5703 in PCIX mode.  This is needed to
> prevent some tx timeouts.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

ACK patches 2-8


