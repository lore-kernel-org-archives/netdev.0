From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] fib: fib_rules_cleanup can be static
Date: Tue, 05 Oct 2010 00:49:04 -0700 (PDT)
Message-ID: <20101005.004904.124001779.davem@davemloft.net>
References: <20101005151417.57eae0b0@s6510>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54761
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757756Ab0JEHsn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Oct 2010 03:48:43 -0400
In-Reply-To: <20101005151417.57eae0b0@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 5 Oct 2010 15:14:17 +0900

> fib_rules_cleanup_ups is only defined and used in one place.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
