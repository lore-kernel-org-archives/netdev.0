From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] Make possible speeds known to ethtool
Date: Fri, 06 Mar 2009 06:19:04 -0500
Message-ID: <49B106A8.1030207@pobox.com>
References: <200901080203.SAA19103@tardy.cup.hp.com> <1231384446.2677.32.camel@hashbaz.i.decadent.org.uk> <49656F01.3090603@pobox.com> <20090109025244.GA11336@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Rick Jones <rick.jones2@hp.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:55350 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755776AbZCFLTO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Mar 2009 06:19:14 -0500
In-Reply-To: <20090109025244.GA11336@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Thu, Jan 08, 2009 at 03:12:01AM +0000, Jeff Garzik wrote:
>> The next release of ethtool is coming in about 4 weeks, and we can  
>> definitely get something like this in there.
> 
> Jeff, any chance you can stick this patch in there to add the GRO
> toggle?
> 
> ethtool: Add GRO toggle
> 
> This patch adds the -k toggles to query and set GRO on a device.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

ugh.  this got buried in my mailbox, sorry.

I missed it completely... and recreated it from scratch just now.  Check 
the git repo, it should work now.

	Jeff




