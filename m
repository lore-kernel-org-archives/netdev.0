From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] can: netlink support for bus-error
 reporting and counters
Date: Fri, 26 Feb 2010 01:49:24 -0800 (PST)
Message-ID: <20100226.014924.181068694.davem@davemloft.net>
References: <4B838FFD.5070302@grandegger.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, socketcan-core@lists.berlios.de
To: wg@grandegger.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49069
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S935768Ab0BZJtI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2010 04:49:08 -0500
In-Reply-To: <4B838FFD.5070302@grandegger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wolfgang Grandegger <wg@grandegger.com>
Date: Tue, 23 Feb 2010 09:21:17 +0100

> This patch makes the bus-error reporting configurable and allows to
> retrieve the CAN TX and RX bus error counters via netlink interface.
> I have added support for the SJA1000. The TX and RX bus error counters
> are also copied to the data fields 6..7 of error messages when state
> changes are reported.
> 
> Signed-off-by: Wolfgang Grandegger <wg@grandegger.com>

Applied.
