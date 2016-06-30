From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/6] BPF helper improvements
Date: Thu, 30 Jun 2016 05:55:14 -0400 (EDT)
Message-ID: <20160630.055514.693480472943841525.davem@davemloft.net>
References: <cover.1467106474.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, tgraf@suug.ch, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54213 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751565AbcF3J4H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2016 05:56:07 -0400
In-Reply-To: <cover.1467106474.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Tue, 28 Jun 2016 12:18:22 +0200

> This set adds various BPF helper improvements, that is, cleaning
> up and adding BPF_F_CURRENT_CPU flag for tracing helper, allowing
> for preemption checks on bpf_get_smp_processor_id() helper, and
> adding two new helpers bpf_skb_change_{proto, type} for tc related
> programs. For further details please see individual patches.
> 
> Note, this set requires -net to be merged into -net-next tree first.

Series applied, thanks.
