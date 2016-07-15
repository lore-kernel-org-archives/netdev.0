From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/3] BPF event output helper improvements
Date: Fri, 15 Jul 2016 14:24:11 -0700 (PDT)
Message-ID: <20160715.142411.2204537177029129115.davem@davemloft.net>
References: <cover.1468511632.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, peterz@infradead.org, tgraf@suug.ch,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54430 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751430AbcGOVYM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2016 17:24:12 -0400
In-Reply-To: <cover.1468511632.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Thu, 14 Jul 2016 18:08:02 +0200

> This set adds improvements to the BPF event output helper to
> support non-linear data sampling, here specifically, for skb
> context. For details please see individual patches. The set
> is based against net-next tree.
> 
> v1 -> v2:
>   - Integrated and adapted Peter's diff into patch 1, updated
>     the remaining ones accordingly. Thanks Peter!
> 
> Thanks a lot!

Series applied, thanks Daniel.
