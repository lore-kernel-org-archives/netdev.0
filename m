From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] be2net: use device model DMA API
Date: Thu, 03 Feb 2011 20:49:55 -0800 (PST)
Message-ID: <20110203.204955.226760498.davem@davemloft.net>
References: <c6e8a0f7-efdf-498e-9647-b544bc4adf34@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ivecera@redhat.com, netdev@vger.kernel.org,
	sathya.perla@emulex.com, subramanian.seetharaman@emulex.com
To: ajit.khaparde@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59134
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751498Ab1BDEtU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Feb 2011 23:49:20 -0500
In-Reply-To: <c6e8a0f7-efdf-498e-9647-b544bc4adf34@exht1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ajit Khaparde <ajit.khaparde@emulex.com>
Date: Thu, 3 Feb 2011 22:39:25 -0600

> -----Original Message-----
>> From: David Miller [mailto:davem@davemloft.net] 
>> Sent: Wednesday, February 02, 2011 4:57 PM
>> To: ivecera@redhat.com
>> Cc: netdev@vger.kernel.org; Perla, Sathya; Seetharaman, Subramanian; Bandi, Sarveshwar; Khaparde, Ajit
>> Subject: Re: [PATCH] be2net: use device model DMA API
> 
>> From: Ivan Vecera <ivecera@redhat.com>
>> Date: Wed,  2 Feb 2011 19:05:12 +0100
> 
>> > Use DMA API as PCI equivalents will be deprecated.
>> > 
>> > Signed-off-by: Ivan Vecera <ivecera@redhat.com>
> 
>> Looks good to me, can I get some review from the be2net maintainers?
> 
> Looks good. Thanks.
> 
> Acked-by: Ajit Khaparde <ajit.khaparde@emulex.com>

Applied, thanks.
