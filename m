From: David Miller <davem@davemloft.net>
Subject: Re: IPSEC maintainership...
Date: Tue, 16 Oct 2012 02:14:35 -0400 (EDT)
Message-ID: <20121016.021435.220828722592000976.davem@davemloft.net>
References: <20121015.133833.2211899390966002142.davem@davemloft.net>
	<20121016061154.GF21577@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54987 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751880Ab2JPGOi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2012 02:14:38 -0400
In-Reply-To: <20121016061154.GF21577@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Tue, 16 Oct 2012 08:11:54 +0200

> On Mon, Oct 15, 2012 at 01:38:33PM -0400, David Miller wrote:
>> 
>> Steffen, after some discussions with Herbert we'd like to formally
>> recognize your outstanding contributions to the IPSEC stack over
>> the past few years by listing you explicitly as a maintainer as
>> per the patch below.
>> 
>> Let us know if you are OK with this.
> 
> I'm absolutely OK with this, of course :)
> 
> Being one of the maintainers, I'd like to run our automated IPsec
> tests on incomming paches before they get applied. So I'd think
> about a workflow and propose something if you are OK with that.

If you want you can maintainer an IPSEC GIT tree, where you apply any
submitted IPSEC changes.

Once you are satisfied with their quality and they pass your tests,
you simply send me a formal GIT pull request just like any other
networking subsystem (netfilter, wireless, etc.) currently does.
