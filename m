From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bpf, elf: add official ELF machine define for
 eBPF
Date: Wed, 20 Jul 2016 12:37:49 -0700 (PDT)
Message-ID: <20160720.123749.1466220963632605263.davem@davemloft.net>
References: <d7fb256f1011ef948809f1447f745da42da970a3.1469038166.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53974 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750804AbcGTThu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2016 15:37:50 -0400
In-Reply-To: <d7fb256f1011ef948809f1447f745da42da970a3.1469038166.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Wed, 20 Jul 2016 20:17:47 +0200

> Add the official BPF ELF e_machine value that was assigned recently [1,2]
> and will be propagated to glibc, et al. LLVM is switching to it in 3.9
> release.
> 
>   [1] https://github.com/llvm-mirror/llvm/commit/36b9c09330bfb5e771914cfe307588f30d5510d2
>   [2] http://lists.iovisor.org/pipermail/iovisor-dev/2016-June/000266.html
> 
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> Acked-by: Alexei Starovoitov <ast@kernel.org>

Applied, thanks.
