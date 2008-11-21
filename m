From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/9] fddi: convert to new network device ops
Date: Thu, 20 Nov 2008 20:31:18 -0800 (PST)
Message-ID: <20081120.203118.190170209.davem@davemloft.net>
References: <20081120175913.943543638@vyatta.com>
	<20081120175933.837997092@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48132
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751539AbYKUEbS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2008 23:31:18 -0500
In-Reply-To: <20081120175933.837997092@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Thu, 20 Nov 2008 09:59:17 -0800

> Similar to ethernet. Convert infrastructure and the one lone FDDI
> driver (for the one lone user of that hardware??). Compile tested only.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
