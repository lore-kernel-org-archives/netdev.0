From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bpf, doc: also add s390x as arch to sysctl
 description
Date: Sun, 20 Aug 2017 19:45:27 -0700 (PDT)
Message-ID: <20170820.194527.138351947367533614.davem@davemloft.net>
References: <23b5525b786a641eb777cf44839fd98189d27acb.1503267753.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@fb.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48832 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753470AbdHUCpd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 20 Aug 2017 22:45:33 -0400
In-Reply-To: <23b5525b786a641eb777cf44839fd98189d27acb.1503267753.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Mon, 21 Aug 2017 00:26:03 +0200

> Looks like this was accidentally missed, so still add s390x
> as supported eBPF JIT arch to bpf_jit_enable.
> 
> Fixes: 014cd0a368dc ("bpf: Update sysctl documentation to list all supported architectures")
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Applied, thanks.
