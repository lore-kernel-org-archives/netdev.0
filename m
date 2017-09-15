From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net] bpf/verifier: reject BPF_ALU64|BPF_END
Date: Fri, 15 Sep 2017 20:01:59 +0200
Message-ID: <59BC1597.20407@iogearbox.net>
References: <8c3d5513-6171-3e68-56df-1efd0e87f071@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Edward Cree <ecree@solarflare.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:49563 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751773AbdIOSCG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 15 Sep 2017 14:02:06 -0400
In-Reply-To: <8c3d5513-6171-3e68-56df-1efd0e87f071@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/15/2017 03:37 PM, Edward Cree wrote:
> Neither ___bpf_prog_run nor the JITs accept it.
> Also adds a new test case.
>
> Fixes: 17a5267067f3 ("bpf: verifier (add verifier core)")
> Signed-off-by: Edward Cree <ecree@solarflare.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
