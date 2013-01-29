From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH V2 0/6] net: frag performance tuning
 cachelines for NUMA/SMP systems
Date: Tue, 29 Jan 2013 13:38:25 -0500 (EST)
Message-ID: <20130129.133825.2102060433138975917.davem@davemloft.net>
References: <20130129094331.13513.28377.stgit@dragon>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, fw@strlen.de, netdev@vger.kernel.org,
	pablo@netfilter.org, amwang@redhat.com, kaber@trash.net,
	herbert@gondor.hengli.com.au, dborkman@redhat.com
To: brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58750 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753068Ab3A2Si2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2013 13:38:28 -0500
In-Reply-To: <20130129094331.13513.28377.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Tue, 29 Jan 2013 10:44:01 +0100

> This patchset is V2, with some trivial code fixes, which were noticed
> by DaveM. It is still a partly respin of my fragmentation optimization
> patches: http://thread.gmane.org/gmane.linux.network/250914

Series applied, thanks Jesper.
