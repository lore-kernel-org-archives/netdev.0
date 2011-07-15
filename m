From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] slcan: remove obsolete code in slcan
 initialisation
Date: Fri, 15 Jul 2011 08:09:24 -0700 (PDT)
Message-ID: <20110715.080924.1343297154392522314.davem@davemloft.net>
References: <4E1FF0FF.2020808@hartkopp.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, matvejchikov@gmail.com
To: socketcan@hartkopp.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41108 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751956Ab1GOPKa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2011 11:10:30 -0400
In-Reply-To: <4E1FF0FF.2020808@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Hartkopp <socketcan@hartkopp.net>
Date: Fri, 15 Jul 2011 09:49:19 +0200

> This patch removes obsolete code in the initialisation/creation of
> slcan devices.
> 
> It follows the suggested cleanups from Ilya Matvejchikov in
> drivers/net/slip.c that where recently applied to net-next-2.6:
> 
> - slip: remove dead code within the slip initialization
> - slip: remove redundant check slip_devs for NULL
> 
> Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>

Applied.
