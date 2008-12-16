From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2.6.29 04/14] gianfar: Optimize interrupt coalescing
 configuration
Date: Tue, 16 Dec 2008 15:30:00 -0800 (PST)
Message-ID: <20081216.153000.179856301.davem@davemloft.net>
References: <1229469667-25002-3-git-send-email-afleming@freescale.com>
	<1229469667-25002-4-git-send-email-afleming@freescale.com>
	<1229469667-25002-5-git-send-email-afleming@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, galak@kernel.crashing.org, netdev@vger.kernel.org,
	Dai.Haruki@freescale.com
To: afleming@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52198
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755350AbYLPX36 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2008 18:29:58 -0500
In-Reply-To: <1229469667-25002-5-git-send-email-afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Fleming <afleming@freescale.com>
Date: Tue, 16 Dec 2008 17:20:57 -0600

> Store the interrupt coalescing values in the form in which they will be
> written to the interrupt coalescing registers.  This puts a little overhead
> into the ethtool configuration, and takes it out of the interrupt handler
> 
> Signed-off-by: Dai Haruki <dai.haruki@freescale.com>
> Acked-by: Andy Fleming <afleming@freescale.com>

Applied.
