From: David Miller <davem@davemloft.net>
Subject: Re: [IPV6 04/06]: Increase number of possible routing tables to
 2^32
Date: Thu, 10 Aug 2006 23:11:29 -0700 (PDT)
Message-ID: <20060810.231129.14359292.davem@davemloft.net>
References: <20060810192957.14867.71965.sendpatchset@localhost.localdomain>
	<20060810193003.14867.80798.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, patrick@tykepenguin.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:37061
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751579AbWHKGLT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Aug 2006 02:11:19 -0400
To: kaber@trash.net
In-Reply-To: <20060810193003.14867.80798.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Thu, 10 Aug 2006 21:30:03 +0200 (MEST)

> [IPV6]: Increase number of possible routing tables to 2^32
> 
> Increase number of possible routing tables to 2^32 by replacing iterations
> over all possible table IDs by hash table walking.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Applied.
