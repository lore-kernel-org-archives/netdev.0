From: David Miller <davem@davemloft.net>
Subject: Re: [IPV4 03/06]: Increase number of possible routing tables to
 2^32
Date: Thu, 10 Aug 2006 23:10:53 -0700 (PDT)
Message-ID: <20060810.231053.79266348.davem@davemloft.net>
References: <20060810192957.14867.71965.sendpatchset@localhost.localdomain>
	<20060810193001.14867.59746.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, patrick@tykepenguin.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:36037
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751563AbWHKGKo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Aug 2006 02:10:44 -0400
To: kaber@trash.net
In-Reply-To: <20060810193001.14867.59746.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Thu, 10 Aug 2006 21:30:01 +0200 (MEST)

> [IPV4]: Increase number of possible routing tables to 2^32
> 
> Increase the number of possible routing tables to 2^32 by replacing the
> fixed sized array of pointers by a hash table and replacing iterations
> over all possible table IDs by hash table walking.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Applied.
