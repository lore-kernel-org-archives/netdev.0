From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/4] bridge: change console message interface
Date: Sat, 15 May 2010 23:12:09 -0700 (PDT)
Message-ID: <20100515.231209.184855025.davem@davemloft.net>
References: <20100510193107.722574297@vyatta.com>
	<20100510193320.859557093@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60892
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751677Ab0EPGMA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 May 2010 02:12:00 -0400
In-Reply-To: <20100510193320.859557093@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 10 May 2010 12:31:09 -0700

> Use one set of macro's for all bridge messages.
> 
> Note: can't use netdev_XXX macro's because bridge is purely
> virtual and has no device parent.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
