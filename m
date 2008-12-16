From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2.6.29 11/14] gianfar: Add Scatter Gather support
Date: Tue, 16 Dec 2008 15:36:37 -0800 (PST)
Message-ID: <20081216.153637.238655751.davem@davemloft.net>
References: <1229469667-25002-10-git-send-email-afleming@freescale.com>
	<1229469667-25002-11-git-send-email-afleming@freescale.com>
	<1229469667-25002-12-git-send-email-afleming@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, galak@kernel.crashing.org, netdev@vger.kernel.org,
	Dai.Haruki@freescale.com, poonam.aggrwal@freescale.com
To: afleming@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40683
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753369AbYLPXgf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2008 18:36:35 -0500
In-Reply-To: <1229469667-25002-12-git-send-email-afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Fleming <afleming@freescale.com>
Date: Tue, 16 Dec 2008 17:21:04 -0600

> From: Haruki Dai <Dai.Haruki@freescale.com>
> 
> Scatter Gather support in gianfar driver to handle fragmented frames on
> the transmit side.
> 
> Signed-off-by: Poonam Aggrwal <poonam.aggrwal@freescale.com>
> Signed-off-by: Dai Haruki <dai.haruki@freescale.com>
> Signed-off-by: Andy Fleming <afleming@freescale.com>

Because patch #2 was bogus and didn't apply, that screws
up this patch and probably the rest of the series, which
I'm tossing.

Please resubmit #2, #11, #12, #13, and #14 once you've
fixed everything up and make it relative to what I have
in fact added to net-next-2.6, thanks.
