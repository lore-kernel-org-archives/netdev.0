From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RESEND 2/2] update sunrpc to use in-kernel sockets API
Date: Wed, 09 Aug 2006 17:03:47 -0700 (PDT)
Message-ID: <20060809.170347.122832529.davem@davemloft.net>
References: <20060808.170941.71164303.davem@davemloft.net>
	<1155093402.5731.35.camel@localhost>
	<1155144878.3049.8.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: trond.myklebust@fys.uio.no, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:3040
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932083AbWHJADx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Aug 2006 20:03:53 -0400
To: sri@us.ibm.com
In-Reply-To: <1155144878.3049.8.camel@w-sridhar2.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sridhar Samudrala <sri@us.ibm.com>
Date: Wed, 09 Aug 2006 10:34:38 -0700

> [SUNRPC]: Remove the unnecessary check for highmem in xs_sendpages()
> and call kernel_sendpage() directly.
> 
> Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

Applied to net-2.6.19, thanks a lot Sridhar.
