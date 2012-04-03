From: Roland Stigge <stigge@antcom.de>
Subject: Re: [PATCH] net: lpc_eth: no need to reserve 8 extra bytes in rx
 skb
Date: Wed, 04 Apr 2012 01:42:17 +0200
Message-ID: <4F7B8AD9.9040709@antcom.de>
References: <1333490531.18626.336.camel@edumazet-glaptop> <4F7B7F9B.3050503@antcom.de> <20120403.185813.669644861254543793.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from antcom.de ([188.40.178.216]:55484 "EHLO chuck.antcom.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754142Ab2DCXmT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Apr 2012 19:42:19 -0400
In-Reply-To: <20120403.185813.669644861254543793.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/04/12 00:58, David Miller wrote:
>> Why add curly braces around a single statement?
> 
> Because that's how we roll for else statements homie, see CodingStyle

Oops :-) sorry you two!

Thanks,

Roland
