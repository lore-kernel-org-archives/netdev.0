From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] arp: remove unnecessary export of
 arp_broken_ops
Date: Wed, 29 Sep 2010 19:46:52 -0700 (PDT)
Message-ID: <20100929.194652.212691213.davem@davemloft.net>
References: <20100929120802.2f642d0d@s6510>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34968
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752452Ab0I3Cqb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Sep 2010 22:46:31 -0400
In-Reply-To: <20100929120802.2f642d0d@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 29 Sep 2010 12:08:02 +0900

> arp_broken_ops is only used in arp.c
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
