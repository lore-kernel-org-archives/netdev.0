From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.22-rc7] xfrm state selection update to use
 inner addresses
Date: Thu, 26 Jul 2007 00:08:51 -0700 (PDT)
Message-ID: <20070726.000851.95060327.davem@davemloft.net>
References: <469FBECB.6080204@trash.net>
	<200707231119.25457.joakim.koskela@hiit.fi>
	<46A60D50.804@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joakim.koskela@hiit.fi, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55300
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1762553AbXGZHIv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jul 2007 03:08:51 -0400
In-Reply-To: <46A60D50.804@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Tue, 24 Jul 2007 16:31:44 +0200

> Joakim Koskela wrote:
> > This patch modifies the xfrm state selection logic to use the inner
> > addresses where the outer have been (incorrectly) used. This is
> > required for beet mode in general and interfamily setups in both
> > tunnel and beet mode.
> 
> 
> Looks good.
> 
> Acked-by: Patrick McHardy <kaber@trash.net>

Applied, thanks everyone.
