From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH][be2net] Add GRO support to the be2net
 driver. LRO is not supported anymore.
Date: Thu, 23 Jul 2009 09:13:41 -0700 (PDT)
Message-ID: <20090723.091341.39177118.davem@davemloft.net>
References: <20090721120701.GA7570@serverengines.com>
	<20090721.123635.76413778.davem@davemloft.net>
	<20090723061824.GE7646@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ajitk@serverengines.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51917
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754332AbZGWQNf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jul 2009 12:13:35 -0400
In-Reply-To: <20090723061824.GE7646@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ajit Khaparde <ajitk@serverengines.com>
Date: Thu, 23 Jul 2009 11:48:26 +0530

> On 21/07/09 12:36 -0700, David Miller wrote:
>> From: Ajit Khaparde <ajitk@serverengines.com>
>> Date: Tue, 21 Jul 2009 17:37:11 +0530
>> 
>> > 
>> > This patch removes support for INET_LRO and switches over to GRO.
>> >
>> > Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
>> 
>> Applied, thanks a lot for doing this work.
> 
> Dave, I just finished a git pull, but don't see the changes. 
> What could be the reason?

I don't always push things immediately, sometimes I give it a few days
before pushing to kernel.org so that build failures and objections to
changes can be dealt with more cleanly.
