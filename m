From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH] dsa/mv88e6060: support nonzero mii base address
Date: Mon, 7 Mar 2011 19:24:13 +0100
Message-ID: <20110307182413.GZ16649@mail.wantstofly.org>
References: <1299512987-11152-1-git-send-email-jacmet@sunsite.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Peter Korsgaard <jacmet@sunsite.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fw.wantstofly.org ([80.101.37.227]:51060 "EHLO
	mail.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754162Ab1CGSYO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2011 13:24:14 -0500
Content-Disposition: inline
In-Reply-To: <1299512987-11152-1-git-send-email-jacmet@sunsite.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 07, 2011 at 04:49:47PM +0100, Peter Korsgaard wrote:

> The mv88e6060 uses either the lower 16 or upper 16 mii addresses,
> depending on the value of the EE_CLK/ADDR4 pin. Support both
> configurations by using the sw_addr setting as base address.
> 
> Signed-off-by: Peter Korsgaard <jacmet@sunsite.dk>

Looks good!

Acked-by: Lennert Buytenhek <buytenh@wantstofly.org>
