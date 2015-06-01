From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] ebpf: misc core cleanup
Date: Sun, 31 May 2015 21:45:17 -0700 (PDT)
Message-ID: <20150531.214517.222222147244891819.davem@davemloft.net>
References: <cover.1432912637.git.daniel@iogearbox.net>
	<cover.1432912637.git.daniel@iogearbox.net>
	<331333f9ad9f3317ebf128ee90eb32e64404029e.1432912637.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@plumgrid.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45386 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757809AbbFAEpS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2015 00:45:18 -0400
In-Reply-To: <331333f9ad9f3317ebf128ee90eb32e64404029e.1432912637.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Fri, 29 May 2015 23:23:07 +0200

> Besides others, move bpf_tail_call_proto to the remaining definitions
> of other protos, improve comments a bit (i.e. remove some obvious ones,
> where the code is already self-documenting, add objectives for others),
> simplify bpf_prog_array_compatible() a bit.
> 
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Applied.
