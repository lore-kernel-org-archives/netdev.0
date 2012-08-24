From: Timur Tabi <timur@freescale.com>
Subject: Re: [linuxppc-release] [PATCH] net/fsl_pq_mdio: add support for the
 Fman 1G MDIO controller
Date: Fri, 24 Aug 2012 15:24:33 -0500
Message-ID: <5037E301.2080805@freescale.com>
References: <1345757047-14657-1-git-send-email-timur@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
To: Andy Fleming <afleming@freescale.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe006.messaging.microsoft.com ([216.32.180.16]:51994
	"EHLO va3outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753539Ab2HXUYm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2012 16:24:42 -0400
In-Reply-To: <1345757047-14657-1-git-send-email-timur@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Timur Tabi wrote:
> The MDIO controller on the Frame Manager (Fman) is compatible with the
> QE and Gianfar MDIO controllers, but we don't care about the TBI because
> the Ethernet drivers (FMD) take care of programming it.
> 
> Signed-off-by: Timur Tabi <timur@freescale.com>

This patch isn't quite right.  I'll post a new version soon.

-- 
Timur Tabi
Linux kernel developer at Freescale
