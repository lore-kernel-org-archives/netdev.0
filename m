From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: [PATCH v4] Network driver for the Armada 370 and Armada XP ARM
 Marvell SoCs
Date: Tue, 30 Oct 2012 10:51:54 +0100
Message-ID: <20121030105154.5b7c8e48@skate>
References: <1351245804-31478-1-git-send-email-thomas.petazzoni@free-electrons.com>
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
Received: from mail.free-electrons.com ([88.190.12.23]:49896 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755430Ab2J3JwJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Oct 2012 05:52:09 -0400
In-Reply-To: <1351245804-31478-1-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Fri, 26 Oct 2012 12:03:20 +0200, Thomas Petazzoni wrote:

> This patch set adds a new network driver for the network unit
> available in the newest Marvell ARM SoCs Armada 370 and Armada XP, as
> well as the necessary Device Tree information to use this driver in
> the two evaluation platforms of those SoCs.

Besides Nobuhiro's small comment on the Device Tree part, are there any
comments on the driver itself, or is the code good to go?

I can send a fifth version with just the fix for Nobuhiro's comment,
but it probably makes sense to take into account a few more comments
(if any) at the same time.

Thanks for your review,

Thomas
-- 
Thomas Petazzoni, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
