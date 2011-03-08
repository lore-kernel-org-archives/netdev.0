From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] dsa/mv88e6060: support nonzero mii base address
Date: Tue, 08 Mar 2011 14:24:34 -0800 (PST)
Message-ID: <20110308.142434.189696408.davem@davemloft.net>
References: <1299512987-11152-1-git-send-email-jacmet@sunsite.dk>
	<20110307182413.GZ16649@mail.wantstofly.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jacmet@sunsite.dk, netdev@vger.kernel.org
To: buytenh@wantstofly.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55661
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754746Ab1CHWX5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2011 17:23:57 -0500
In-Reply-To: <20110307182413.GZ16649@mail.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lennert Buytenhek <buytenh@wantstofly.org>
Date: Mon, 7 Mar 2011 19:24:13 +0100

> On Mon, Mar 07, 2011 at 04:49:47PM +0100, Peter Korsgaard wrote:
> 
>> The mv88e6060 uses either the lower 16 or upper 16 mii addresses,
>> depending on the value of the EE_CLK/ADDR4 pin. Support both
>> configurations by using the sw_addr setting as base address.
>> 
>> Signed-off-by: Peter Korsgaard <jacmet@sunsite.dk>
> 
> Looks good!
> 
> Acked-by: Lennert Buytenhek <buytenh@wantstofly.org>

Applied, thanks.
