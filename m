From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/4] net: filter: BPF updates
Date: Tue, 19 Mar 2013 10:38:03 -0400 (EDT)
Message-ID: <20130319.103803.368214683799955215.davem@davemloft.net>
References: <cover.1363702456.git.dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, jasowang@redhat.com
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43345 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755520Ab3CSOiH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Mar 2013 10:38:07 -0400
In-Reply-To: <cover.1363702456.git.dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Tue, 19 Mar 2013 15:33:59 +0100

> This set adds i) an ancillary operation to the BPF engine and ii) a
> BPF JIT image disassembler in order to verify or debug the BPF JIT
> compilers under arch/*/net/.
> 
> v1 -> v2:
> 	- No need to reorder choke_skb_cb structure

So we want the first patch in 'net' right?
