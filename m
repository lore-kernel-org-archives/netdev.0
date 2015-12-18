From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/5] Misc BPF updates
Date: Fri, 18 Dec 2015 16:05:34 -0500 (EST)
Message-ID: <20151218.160534.1560352985560339833.davem@davemloft.net>
References: <cover.1450391511.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@kernel.org, holzheu@linux.vnet.ibm.com, zlim.lnx@gmail.com,
	netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45453 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965506AbbLRVFg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Dec 2015 16:05:36 -0500
In-Reply-To: <cover.1450391511.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Thu, 17 Dec 2015 23:51:52 +0100

> This series contains a couple of misc updates to the BPF code, besides
> others a new helper bpf_skb_load_bytes(), moving clearing of A/X to the
> classic converter, etc. Please see individual patches for details.

Series applied, thanks Daniel.
