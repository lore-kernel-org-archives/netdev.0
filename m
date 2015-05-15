From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] test_bpf: add tests related to BPF_MAXINSNS
Date: Thu, 14 May 2015 22:34:37 -0400 (EDT)
Message-ID: <20150514.223437.1566952930083891574.davem@davemloft.net>
References: <f35ca0ee7ba9a7a934dc6131a32fafa941d8dcad.1431515140.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ast@plumgrid.com, nschichan@freebox.fr
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44092 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422918AbbEOCei (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2015 22:34:38 -0400
In-Reply-To: <f35ca0ee7ba9a7a934dc6131a32fafa941d8dcad.1431515140.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Wed, 13 May 2015 13:12:43 +0200

> Couple of torture test cases related to the bug fixed in 0b59d8806a31
> ("ARM: net: delegate filter to kernel interpreter when imm_offset()
> return value can't fit into 12bits.").
> 
> I've added a helper to allocate and fill the insn space. Output on
> x86_64 from my laptop:
 ...
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Applied, thanks.
