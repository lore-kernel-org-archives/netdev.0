From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: remove unnecessary include
Date: Sat, 28 Oct 2017 19:27:46 +0900 (KST)
Message-ID: <20171028.192746.1398411172557523315.davem@davemloft.net>
References: <20171027170139.2811283-1-ast@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, brakmo@fb.com, netdev@vger.kernel.org
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34182 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751001AbdJ1K1x (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 28 Oct 2017 06:27:53 -0400
In-Reply-To: <20171027170139.2811283-1-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@fb.com>
Date: Fri, 27 Oct 2017 10:01:39 -0700

> two extra #include are not necessary in tcp.h
> Remove them.
> 
> Fixes: 40304b2a1567 ("bpf: BPF support for sock_ops")
> Signed-off-by: Alexei Starovoitov <ast@kernel.org>

Applied, thank you.
