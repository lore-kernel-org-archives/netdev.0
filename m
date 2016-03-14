From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2 0/4] Few mvneta fixes
Date: Mon, 14 Mar 2016 15:49:45 -0400 (EDT)
Message-ID: <20160314.154945.1770938851011099663.davem@davemloft.net>
References: <1457804660-8463-1-git-send-email-gregory.clement@free-electrons.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	thomas.petazzoni@free-electrons.com, jason@lakedaemon.net,
	andrew@lunn.ch, sebastian.hesselbarth@gmail.com,
	linux-arm-kernel@lists.infradead.org, alior@marvell.com,
	nadavh@marvell.com, mw@semihalf.com, patrick@puiterwijk.org,
	dima@marvell.com, oferh@marvell.com
To: gregory.clement@free-electrons.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49249 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755505AbcCNTtt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2016 15:49:49 -0400
In-Reply-To: <1457804660-8463-1-git-send-email-gregory.clement@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Date: Sat, 12 Mar 2016 18:44:16 +0100

> In this second version I split the last patch in two parts as
> requested.
> 
> For the record the initial cover letter was:
> "here is a patch set of few fixes. Without the first one, a kernel
> configured with debug features ended to hang when the driver is built
> as a module and is removed. This is quite is annoying for debugging!
> 
> The second patch fix a forgotten flag at the initial submission of the
> driver.
> 
> The third patch is only really a cosmetic one so I have no problem to
> not apply it for 4.5 and wait for 4.6.
> 
> I really would like to see the first one applied for 4.5 and for the
> second I let you judge if it something needed for now or that should
> wait the next release."

Series applied and patches #1 and #2 queued up for -stable, thanks.
