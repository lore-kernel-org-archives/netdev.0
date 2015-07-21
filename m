From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/2] bpf: introduce bpf_skb_vlan_push/pop()
 helpers
Date: Mon, 20 Jul 2015 20:52:45 -0700 (PDT)
Message-ID: <20150720.205245.649321634564529110.davem@davemloft.net>
References: <1437449659-23765-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, holzheu@linux.vnet.ibm.com,
	daniel@iogearbox.net, netdev@vger.kernel.org
To: ast@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54612 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751489AbbGUDwr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jul 2015 23:52:47 -0400
In-Reply-To: <1437449659-23765-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@plumgrid.com>
Date: Mon, 20 Jul 2015 20:34:17 -0700

> Let TC+eBPF programs call skb_vlan_push/pop via helpers.
> 
> v1->v2:
> - reworded commit log to better explain correctness of re-caching
>   and fixed comparison of mixed endiannes (suggested by Eric)

Series applied, thanks Alexei.
