From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 1/11] ibm_newemac: Add BCM5248 and Marvell 88E1111 PHY
	support
Date: Fri, 30 Nov 2007 07:56:41 +0000
Message-ID: <20071130075641.GA16650@infradead.org>
References: <1196401223.5661.297518056501.qpush@grosgo> <20071130054126.39BDCDDE0A@ozlabs.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:40171 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752593AbXK3H4s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Nov 2007 02:56:48 -0500
Content-Disposition: inline
In-Reply-To: <20071130054126.39BDCDDE0A@ozlabs.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 30, 2007 at 04:40:23PM +1100, Benjamin Herrenschmidt wrote:
> From: Stefan Roese <sr@denx.de>
> 
> This patch adds BCM5248 and Marvell 88E1111 PHY support to NEW EMAC driver.
> These PHY chips are used on PowerPC 440EPx boards.
> The PHY code is based on the previous work by Stefan Roese <sr@denx.de>

Is there a reason the emac driver isn't using the generic phy code?

