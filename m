From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/5] s390/bpf: recache skb->data/hlen for
 skb_vlan_push/pop
Date: Wed, 29 Jul 2015 15:00:14 -0700 (PDT)
Message-ID: <20150729.150014.82183966921783124.davem@davemloft.net>
References: <1438197318-16903-1-git-send-email-holzheu@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@plumgrid.com, schwidefsky@de.ibm.com, daniel@iogearbox.net,
	joe@perches.com, netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: holzheu@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34417 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753341AbbG2WAP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2015 18:00:15 -0400
In-Reply-To: <1438197318-16903-1-git-send-email-holzheu@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Holzheu <holzheu@linux.vnet.ibm.com>
Date: Wed, 29 Jul 2015 21:15:13 +0200

> Here the s390 backend for Alexei's patch 4e10df9a60d9 ("bpf: introduce
> bpf_skb_vlan_push/pop() helpers") plus two bugfixes and two minor
> improvements.
> 
> The first patch "s390/bpf: clear correct BPF accumulator register" will
> also go upstream via Martin's "fixes" branch.
> 
> * v2: Integrated suggestions from Joe Perches

Series applied, thanks.
