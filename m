From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/9] sky2: reduce default transmit ring
Date: Wed, 17 Jun 2009 18:51:11 -0700 (PDT)
Message-ID: <20090617.185111.238554665.davem@davemloft.net>
References: <20090617173031.703636683@vyatta.com>
	<20090617173140.074593860@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51059
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753021AbZFRBvH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2009 21:51:07 -0400
In-Reply-To: <20090617173140.074593860@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 17 Jun 2009 10:30:37 -0700

> Reduce the size of the driver transmit ring to reduce latency
> and allow qdisc to do better rate control.  Also make it
> obvious what the minimum transmit ring allowed is and why.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
