From: Stefan Roese <sr@denx.de>
Subject: Re: [PATCH] ibm_newemac: Increase number of default rx-/tx-buffers
Date: Sat, 5 Jan 2008 13:38:17 +0100
Message-ID: <200801051338.17957.sr@denx.de>
References: <1199526609-12290-1-git-send-email-sr@denx.de> <1199528388.7291.55.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: benh@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.183]:64739 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753969AbYAEMi1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jan 2008 07:38:27 -0500
In-Reply-To: <1199528388.7291.55.camel@pasglop>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 05 January 2008, Benjamin Herrenschmidt wrote:
> On Sat, 2008-01-05 at 10:50 +0100, Stefan Roese wrote:
> > Performance tests done by AMCC have shown that 256 buffer increase the
> > performance of the Linux EMAC driver. So let's update the default
> > values to match this setup.
> >
> > Signed-off-by: Stefan Roese <sr@denx.de>
> > ---
>
> Do we have the numbers ? Did they also measure latency ?

I hoped this question would not come. ;) No, unfortunately I don't have any 
numbers. Just the recommendation from AMCC to always use 256 buffers.

Best regards,
Stefan
