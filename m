From: David Miller <davem@davemloft.net>
Subject: Re: can: add sanity checks
Date: Sat, 05 Jul 2008 23:39:00 -0700 (PDT)
Message-ID: <20080705.233900.251289513.davem@davemloft.net>
References: <486BCCA0.9040006@hartkopp.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: urs.thuermann@volkswagen.de, oliver.hartkopp@volkswagen.de,
	nautsch@gmail.com, netdev@vger.kernel.org, stable@kernel.org
To: oliver@hartkopp.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51296
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751678AbYGFGjB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Jul 2008 02:39:01 -0400
In-Reply-To: <486BCCA0.9040006@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Hartkopp <oliver@hartkopp.net>
Date: Wed, 02 Jul 2008 20:44:48 +0200

> Even though the CAN netlayer only deals with CAN netdevices, the 
> netlayer interface to the userspace and to the device layer should 
> perform some sanity checks.
> 
> This patch adds several sanity checks that mainly prevent userspace apps 
> to send broken content into the system that may be misinterpreted by 
> some other userspace application.
> 
> Signed-off-by: Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
> Signed-off-by: Urs Thuermann <urs.thuermann@volkswagen.de>
> Acked-by: Andre Naujoks <nautsch@gmail.com>

Applied to net-2.6, thanks Oliver.
