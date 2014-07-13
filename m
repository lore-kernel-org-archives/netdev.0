From: Jason Cooper <jason@lakedaemon.net>
Subject: Re: [PATCH v4 net-next 0/4] Network driver for Armada 375 SoC
Date: Sun, 13 Jul 2014 17:56:20 -0400
Message-ID: <20140713215620.GF13108@titan.lakedaemon.net>
References: <1405021936-28658-1-git-send-email-ezequiel.garcia@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	David Miller <davem@davemloft.net>,
	Marcin Wojtas <mw@semihalf.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Tawfik Bayouk <tawfik@marvell.com>,
	Lior Amsalem <alior@marvell.com>
To: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mho-02-ewr.mailhop.org ([204.13.248.72]:60961 "EHLO
	mho-02-ewr.mailhop.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751979AbaGMV42 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jul 2014 17:56:28 -0400
Content-Disposition: inline
In-Reply-To: <1405021936-28658-1-git-send-email-ezequiel.garcia@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 10, 2014 at 04:52:12PM -0300, Ezequiel Garcia wrote:
> If there's nothing else to fix, we'd like to merge this for v3.17. The first
> patch should go through the network tree, and the other patches through
> the mvebu tree.

Patches 2 and 3 applied to mvebu/dt, #4 to mvebu/defconfig.

thx,

Jason.
