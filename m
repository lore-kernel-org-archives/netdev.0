From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] BPF update
Date: Mon, 11 Jan 2016 17:33:09 -0500 (EST)
Message-ID: <20160111.173309.1543986120233268415.davem@davemloft.net>
References: <cover.1452385316.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, tgraf@suug.ch, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41968 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759922AbcAKWdK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2016 17:33:10 -0500
In-Reply-To: <cover.1452385316.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Mon, 11 Jan 2016 01:16:37 +0100

> This set adds IPv6 support for bpf_skb_{set,get}_tunnel_key() helper.
> It also exports flags to user space that are being used in helpers and
> weren't exported thus far. For more details, please see the individual
> patches.

Series applied, thank you.
