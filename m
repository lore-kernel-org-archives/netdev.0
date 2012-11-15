From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: [PATCH v7] Network driver for the Armada 370 and Armada XP ARM
 Marvell SoCs
Date: Thu, 15 Nov 2012 09:02:57 +0100
Message-ID: <20121115090257.4b9e20c5@skate>
References: <1352905010-24172-1-git-send-email-thomas.petazzoni@free-electrons.com>
	<20121114.215922.1242337385782766449.davem@davemloft.net>
	<20121115083319.76483256@skate>
	<20121115.024213.1356436436054345008.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, kernel@wantstofly.org,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	jason@lakedaemon.net, andrew@lunn.ch,
	gregory.clement@free-electrons.com, alior@marvell.com,
	dima@marvell.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([88.190.12.23]:52366 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2992679Ab2KOIDJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2012 03:03:09 -0500
In-Reply-To: <20121115.024213.1356436436054345008.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David,

On Thu, 15 Nov 2012 02:42:13 -0500 (EST), David Miller wrote:
> From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
> Date: Thu, 15 Nov 2012 08:33:19 +0100
> 
> > Would you mind if we take, with your Ack, the network driver through
> > the arm-soc tree, so that we can carry the related patches modifying
> > the Device Tree and so on? If not, then I'll send you a pull request
> > with just the drivers/net changes, and we'll integrate the ARM-related
> > changes through the arm-soc tree, in which we will have the necessary
> > dependencies. I'm fine with any of those solutions.
> 
> Sure, no problem, take it via the ARM tree:
> 
> Acked-by: David S. Miller <davem@davemloft.net>

Excellent, thanks!

Thomas
-- 
Thomas Petazzoni, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
