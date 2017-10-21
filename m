From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next] selftests/bpf: fix broken build of test_maps
Date: Sat, 21 Oct 2017 10:23:08 +0200
Message-ID: <59EB03EC.9060002@iogearbox.net>
References: <20171021062533.2090015-1-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Chenbo Feng <fengc@google.com>,
        Lorenzo Colitti <lorenzo@google.com>, netdev@vger.kernel.org
To: Alexei Starovoitov <ast@fb.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:42567 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751668AbdJUIXO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 21 Oct 2017 04:23:14 -0400
In-Reply-To: <20171021062533.2090015-1-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/21/2017 08:25 AM, Alexei Starovoitov wrote:
> fix broken tests
>
> Fixes: e043325b3087 ("bpf: Add tests for eBPF file mode")
> Fixes: 6e71b04a8224 ("bpf: Add file mode configuration into bpf maps")
> Signed-off-by: Alexei Starovoitov <ast@kernel.org>
> ---
> Chenbo,
>
> this was very broken patch submission.
> Please make sure to actually compile your tests before sending patches.

Urks, and still after that many rounds ...

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
