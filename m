From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] netfilter: remove dead code
Date: Tue, 29 Sep 2015 21:54:35 -0700 (PDT)
Message-ID: <20150929.215435.823982622418043263.davem@davemloft.net>
References: <1443572700-29705-1-git-send-email-fbl@redhat.com>
	<20150930004507.GH19923@breakpoint.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fbl@redhat.com, netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33413 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751117AbbI3Eyg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2015 00:54:36 -0400
In-Reply-To: <20150930004507.GH19923@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Wed, 30 Sep 2015 02:45:07 +0200

> Flavio Leitner <fbl@redhat.com> wrote:
>> Remove __nf_conntrack_find() from headers.
>> Fixes: dcd93ed4cd1 ("netfilter: nf_conntrack: remove dead code"
> 
> For the record: netfilter patches should go to
> netfilter-devel@vger.kernel.org .
> 
> That being said, in this case I doubt Pablo minds if David takes this
> directly, patch ts obviously correct[tm] :)

I don't want to create any unnecessary merge hassles, so please
resubmit this properly to netfilter-devel, thanks.
