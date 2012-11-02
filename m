From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: [PATCH v4] Network driver for the Armada 370 and Armada XP ARM
 Marvell SoCs
Date: Fri, 2 Nov 2012 23:21:37 +0100
Message-ID: <20121102232137.3c9da5e4@skate>
References: <1351245804-31478-1-git-send-email-thomas.petazzoni@free-electrons.com>
	<20121030105154.5b7c8e48@skate>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Jason Cooper <jason@lakedaemon.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Lior Amsalem <alior@marvell.com>,
	Maen Suleiman <maen@marvell.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Lennert Buytenhek <kernel@wantstofly.org>,
	Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([88.190.12.23]:54830 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753271Ab2KBWVy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Nov 2012 18:21:54 -0400
In-Reply-To: <20121030105154.5b7c8e48@skate>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Tue, 30 Oct 2012 10:51:54 +0100, Thomas Petazzoni wrote:

> > This patch set adds a new network driver for the network unit
> > available in the newest Marvell ARM SoCs Armada 370 and Armada XP,
> > as well as the necessary Device Tree information to use this driver
> > in the two evaluation platforms of those SoCs.
> 
> Besides Nobuhiro's small comment on the Device Tree part, are there
> any comments on the driver itself, or is the code good to go?
> 
> I can send a fifth version with just the fix for Nobuhiro's comment,
> but it probably makes sense to take into account a few more comments
> (if any) at the same time.

Any comments on this patch set? What should I do to make it progress
towards integration?

Thanks,

Thomas
-- 
Thomas Petazzoni, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
