From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH 0/5][RFC][MV643XX_ETH] more cleanups
Date: Wed, 19 Mar 2008 08:34:15 +0100
Message-ID: <20080319073415.GA4717@xi.wantstofly.org>
References: <20080317200427.GA18726@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dale Farnsworth <dale@farnsworth.org>,
	Nicolas Pitre <nico@marvell.com>,
	Tzachi Perelstein <tzachi@marvell.com>,
	Saeed Bishara <saeed@marvell.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:43788 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754064AbYCST12 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2008 15:27:28 -0400
Content-Disposition: inline
In-Reply-To: <20080317200427.GA18726@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 17, 2008 at 09:04:27PM +0100, Lennert Buytenhek wrote:

> This patch series consists of a couple more mv643xx_eth cleanups.
> 
> These cleanups can't be merged yet at this point, as the first one
> (which allows instantiating multiple mv643xx_eth instances)
> inadvertently breaks ppc/powerpc due to changing instantiation
> rules, and the rest of the patches all depend on the first patch.

Dale sent me a patch to fix the ppc bits -- new series coming up.
