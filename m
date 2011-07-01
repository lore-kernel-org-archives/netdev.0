From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: de4x5: Omit check for multicast bit in
 netdev_for_each_mc_addr
Date: Fri, 01 Jul 2011 00:31:04 -0700 (PDT)
Message-ID: <20110701.003104.1560405560789304913.davem@davemloft.net>
References: <1309349760-1776-1-git-send-email-tklauser@distanz.ch>
	<20110630.235730.726339338074212677.davem@davemloft.net>
	<20110701072533.GY28247@distanz.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: grundler@parisc-linux.org, netdev@vger.kernel.org
To: tklauser@distanz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41275 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755201Ab1GAHbJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2011 03:31:09 -0400
In-Reply-To: <20110701072533.GY28247@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>
Date: Fri, 1 Jul 2011 09:25:33 +0200

> On 2011-07-01 at 08:57:30 +0200, David Miller <davem@davemloft.net> wrote:
>> From: Tobias Klauser <tklauser@distanz.ch>
>> Date: Wed, 29 Jun 2011 14:16:00 +0200
>> 
>> > There is no need to check for the address being a multicast address in
>> > the netdev_for_each_mc_addr loop, so remove it.
>> > 
>> > Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
>> 
>> Please build test your patches!
> 
> Sorry for the mess. Here's an updated patch, not removing the addrs
> local variable.
> 
> There is no need to check for the address being a multicast address in
> the netdev_for_each_mc_addr loop, so remove it.
> 
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

Do not mix patch submissions into existing discussions.

Please, instead, make a new fresh patch submission.

Otherwise I have to do a lot of work editing your commit
log messages and the headers.

Thanks.
