From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/7]: [NET]: Fix drivers to handle napi_disable()
 disabling interrupts.
Date: Tue, 08 Jan 2008 22:44:58 -0800 (PST)
Message-ID: <20080108.224458.203158908.davem@davemloft.net>
References: <1199859269.9002.6.camel@Linux.home>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: pcnet32@verizon.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55143
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751271AbYAIGo6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2008 01:44:58 -0500
In-Reply-To: <1199859269.9002.6.camel@Linux.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Fry <pcnet32@verizon.net>
Date: Tue, 08 Jan 2008 22:14:29 -0800

> Tested pcnet32 on x86_64 box and see no problems with the change.
> The code is only exercised if doing loopback testing, or changing
> the ring size during a receive storm.
> 
> Acked-by:  Don Fry <pcnet32@verizon.net>

Thanks for testing and the feedback.
