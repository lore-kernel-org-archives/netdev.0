From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]: can: Add documentation for virtual CAN driver usage
Date: Tue, 23 Sep 2008 14:53:27 -0700 (PDT)
Message-ID: <20080923.145327.07815746.davem@davemloft.net>
References: <48D9274A.407@hartkopp.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, urs@isnogud.escape.de
To: oliver@hartkopp.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39718
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751753AbYIWVxj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2008 17:53:39 -0400
In-Reply-To: <48D9274A.407@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Hartkopp <oliver@hartkopp.net>
Date: Tue, 23 Sep 2008 19:28:42 +0200

> From: Oliver Hartkopp <oliver@hartkopp.net>
> 
> This patch adds a usage documentation for the virtual CAN driver (vcan).
> 
> Signed-off-by: Oliver Hartkopp <oliver@hartkopp.net>
> ---
> 
> Hello Dave,
> 
> the virtual CAN netdevices are created via the netlink interface since Kerenel 2.6.24.
> This patch adds some examples how to create and remove vcans via the ip(8) tool.
> Please consider for net-next-2.6

Applied, thanks Oliver.
