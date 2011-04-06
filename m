From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] dsa/mv88e6131: add support for mv88e6085 switch
Date: Wed, 06 Apr 2011 13:33:04 -0700 (PDT)
Message-ID: <20110406.133304.258116649.davem@davemloft.net>
References: <1302008636-6544-1-git-send-email-jacmet@sunsite.dk>
	<20110405133944.GG22881@wantstofly.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jacmet@sunsite.dk, netdev@vger.kernel.org
To: buytenh@wantstofly.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50947
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755805Ab1DFUdl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2011 16:33:41 -0400
In-Reply-To: <20110405133944.GG22881@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lennert Buytenhek <buytenh@wantstofly.org>
Date: Tue, 5 Apr 2011 15:39:44 +0200

> On Tue, Apr 05, 2011 at 03:03:56PM +0200, Peter Korsgaard wrote:
> 
>> The mv88e6085 is identical to the mv88e6095, except that all ports are
>> 10/100 Mb/s, so use the existing setup code except for the cpu/dsa speed
>> selection in _setup_port().
>> 
>> Signed-off-by: Peter Korsgaard <jacmet@sunsite.dk>
> 
> I don't have access to DSA chip docs anymore, but assuming that you've
> tested this:
> 
> Acked-by: Lennert Buytenhek <buytenh@wantstofly.org>

Applied, thanks.
