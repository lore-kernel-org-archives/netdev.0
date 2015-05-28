From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V4 00/12] net/mlx5: ConnectX-4 100G Ethernet
 driver
Date: Thu, 28 May 2015 01:52:32 -0700 (PDT)
Message-ID: <20150528.015232.1205990019180315319.davem@davemloft.net>
References: <CAJ3xEMiteyRsGuNQoQYiiZKeWkpjQE8WcJdQfWyxntJ9bjYXcw@mail.gmail.com>
	<20150527.133620.1867770619067144773.davem@davemloft.net>
	<1432756657.6319.22.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gerlitz.or@gmail.com, netdev@vger.kernel.org,
	ogerlitz@mellanox.com, talal@mellanox.com, achiad@mellanox.com,
	saeedm@mellanox.com, amirv@mellanox.com, edumazet@google.com,
	tom@herbertland.com, jiri@resnulli.us, bpoirier@suse.de,
	nhorman@tuxdriver.com
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45179 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752886AbbE1Iwg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2015 04:52:36 -0400
In-Reply-To: <1432756657.6319.22.camel@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Wed, 27 May 2015 20:57:37 +0100

> How would an application tell the difference between an IRQ handler
> being renamed, or being unregistered and re-registered under a different
> name?  I'm fairly sure it can't tell.

What do things like the userland IRQ balancer do?
