From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] bpf: couple of fixes
Date: Fri, 10 Jun 2016 18:01:15 -0700 (PDT)
Message-ID: <20160610.180115.1511833272202422951.davem@davemloft.net>
References: <cover.1465578089.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, hannes@stressinduktion.org,
	netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33806 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932489AbcFKBBQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2016 21:01:16 -0400
In-Reply-To: <cover.1465578089.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Fri, 10 Jun 2016 21:19:05 +0200

> These are two fixes for BPF, one to introduce xmit recursion limiter for
> tc bpf programs and the other one to reject filters a bit earlier. For
> more details please see individual patches. I have no strong opinion
> to which tree they should go, they apply to both, but I think net-next
> seems okay to me.

Series applied to net-next, thanks Daniel.
