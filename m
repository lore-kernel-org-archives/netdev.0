From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/2] BPF update
Date: Sun, 10 Jan 2016 17:55:53 -0500 (EST)
Message-ID: <20160110.175553.1974782263022722191.davem@davemloft.net>
References: <cover.1452176592.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, hannes@stressinduktion.org,
	netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58766 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753259AbcAJWzz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jan 2016 17:55:55 -0500
In-Reply-To: <cover.1452176592.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Thu,  7 Jan 2016 15:50:21 +0100

> Fixes a csum issue on ingress. As mentioned previously, net-next
> seems just fine imho. Later on, will follow up with couple of
> replacements like ovs_skb_postpush_rcsum() etc.
> 
> Thanks!
> 
> v1 -> v2:
>   - Added patch 1 with helper
>   - Implemented Hannes' idea to just use csum_partial, thanks!

Series applied.
