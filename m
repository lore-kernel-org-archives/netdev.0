From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next][resubmit] cdc_ether: additional Ericsson MBM
 PID's to the whitelist
Date: Thu, 08 Oct 2009 23:00:41 -0700 (PDT)
Message-ID: <20091008.230041.128312409.davem@davemloft.net>
References: <E86B0C24322D8648AC7F41E7CDA658E903DDD5FD@esealmw114.eemea.ericsson.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: torgny.johansson@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55604
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751904AbZJIGAq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Oct 2009 02:00:46 -0400
In-Reply-To: <E86B0C24322D8648AC7F41E7CDA658E903DDD5FD@esealmw114.eemea.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Torgny Johansson" <torgny.johansson@ericsson.com>
Date: Thu, 8 Oct 2009 16:20:48 +0200

> This is a new attempt to submit a patch that adds seven more PID's to the whitelist set of device. Been having some problems submitting patches with Outlook (yes I know that is a baaad idea :)) but hopefully this will get sent right.
> 
> Devices added to the whitelist:
>  - Ericsson Mobile Broadband variants (F3607gw and F3307)
>  - Dell F3607gw variants
>  - Toshiba F3607gw variants
> 
> Regards 
> Torgny Johansson
> 
> Signed-off-by: Torgny Johansson <torgny.johansson@ericsson.com>

Your patch does not apply cleanly to Linus's current tree, it
produces rejects even with 'patch'.

Please respin your patch against current sources and resubmit,
thank you.
