From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] Misc BPF improvements
Date: Fri, 17 Feb 2017 13:40:25 -0500 (EST)
Message-ID: <20170217.134025.1757715037449350818.davem@davemloft.net>
References: <cover.1487279499.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ast@kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47022 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934365AbdBQSk1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2017 13:40:27 -0500
In-Reply-To: <cover.1487279499.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Thu, 16 Feb 2017 22:24:47 +0100

> This last series for this window adds various misc
> improvements to BPF, one is to mark registered map and
> prog types as __ro_after_init, another one for removing
> cBPF stubs in eBPF JITs and moving the stub to the core
> and last also improving JITs is to make generated images
> visible to the kernel and kallsyms, so they can be
> seen in traces. For details, please have a look at the
> individual patches.
> 
> Thanks a lot!

Series applied, thanks Daniel.
