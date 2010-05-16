From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] bridge: netpoll cleanup
Date: Sat, 15 May 2010 23:12:03 -0700 (PDT)
Message-ID: <20100515.231203.55877701.davem@davemloft.net>
References: <20100510193107.722574297@vyatta.com>
	<20100510193320.775633381@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60886
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751301Ab0EPGLz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 May 2010 02:11:55 -0400
In-Reply-To: <20100510193320.775633381@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 10 May 2010 12:31:08 -0700

> Move code around so that the ifdef for NETPOLL_CONTROLLER don't have to
> show up in main code path. The control functions should be in helpers
> that are only compiled if needed.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
