From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] dsa/mv88e6131: fix unknown multicast/broadcast
 forwarding on mv88e6085
Date: Thu, 28 Apr 2011 13:36:02 -0700 (PDT)
Message-ID: <20110428.133602.245385006.davem@davemloft.net>
References: <1303818341-13839-1-git-send-email-jacmet@sunsite.dk>
	<20110426145740.GL1897@wantstofly.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jacmet@sunsite.dk, netdev@vger.kernel.org
To: buytenh@wantstofly.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55227
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751700Ab1D1Ugg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2011 16:36:36 -0400
In-Reply-To: <20110426145740.GL1897@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lennert Buytenhek <buytenh@wantstofly.org>
Date: Tue, 26 Apr 2011 16:57:40 +0200

> On Tue, Apr 26, 2011 at 01:45:41PM +0200, Peter Korsgaard wrote:
> 
>> The 88e6085 has a few differences from the other devices in the port
>> control registers, causing unknown multicast/broadcast packets to get
>> dropped when using the standard port setup.
>> 
>> At the same time update kconfig to clarify that the mv88e6085 is now
>> supported.
>> 
>> Signed-off-by: Peter Korsgaard <jacmet@sunsite.dk>
> 
> Assuming that you've tested this.. :)
> 
> Acked-by: Lennert Buytenhek <buytenh@wantstofly.org>

Applied, thanks everyone.
