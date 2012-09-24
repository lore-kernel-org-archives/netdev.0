From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] x86: bpf_jit_comp: add XOR instruction for
 BPF JIT
Date: Mon, 24 Sep 2012 19:44:07 +0200
Message-ID: <1348508647.26828.1300.camel@edumazet-glaptop>
References: <20120924173450.GA28969@thinkbox>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Daniel Borkmann <dxchgb@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:44025 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757358Ab2IXRoM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Sep 2012 13:44:12 -0400
Received: by bkcjk13 with SMTP id jk13so1081661bkc.19
        for <netdev@vger.kernel.org>; Mon, 24 Sep 2012 10:44:11 -0700 (PDT)
In-Reply-To: <20120924173450.GA28969@thinkbox>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-09-24 at 19:34 +0200, Daniel Borkmann wrote:
> This patch is a follow-up for patch "filter: add XOR instruction for use
> with X/K" that implements BPF x86 JIT parts for the BPF XOR operation.
> 
> Signed-off-by: Daniel Borkmann <daniel.borkmann@tik.ee.ethz.ch>
> ---
>  arch/x86/net/bpf_jit_comp.c |    9 +++++++++
>  1 files changed, 9 insertions(+), 0 deletions(-)

Acked-by: Eric Dumazet <edumazet@google.com>
