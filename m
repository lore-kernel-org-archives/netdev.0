From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: tcp_enter_quickack_mode can be static
Date: Wed, 29 Sep 2010 19:46:57 -0700 (PDT)
Message-ID: <20100929.194657.258118740.davem@davemloft.net>
References: <20100929143014.7f32cec3@s6510>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34973
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752452Ab0I3Cqh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Sep 2010 22:46:37 -0400
In-Reply-To: <20100929143014.7f32cec3@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 29 Sep 2010 14:30:14 +0900

> Function only used in tcp_input.c
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
