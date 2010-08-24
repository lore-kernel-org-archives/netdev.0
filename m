From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tc: add meta match on receive hash
Date: Tue, 24 Aug 2010 14:48:20 -0700 (PDT)
Message-ID: <20100824.144820.28795576.davem@davemloft.net>
References: <AANLkTik3tnSQOXSQWxX+GqcJpjnEyGuWyZhQ9sbPFYAt@mail.gmail.com>
	<20100823.204422.85408087.davem@davemloft.net>
	<20100824111440.37eebae1@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiaosuo@gmail.com, hadi@cyberus.ca, tgraf@redhat.com,
	netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53383
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755718Ab0HXVsD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Aug 2010 17:48:03 -0400
In-Reply-To: <20100824111440.37eebae1@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 24 Aug 2010 11:14:40 -0700

> Trivial extension to existing meta data match rules to allow
> matching on skb receive hash value.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied, thanks Stephen.

