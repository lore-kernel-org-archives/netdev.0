From: "Wangnan (F)" <wangnan0@huawei.com>
Subject: Re: [PATCH v2 net-next 3/6] tools/lib/bpf: expose
 bpf_program__set_type()
Date: Fri, 31 Mar 2017 15:49:20 +0800
Message-ID: <61323557-be03-6e4a-8b02-a20c63d10b20@huawei.com>
References: <20170331044543.4075183-1-ast@fb.com>
 <20170331044543.4075183-4-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Martin KaFai Lau <kafai@fb.com>, <netdev@vger.kernel.org>,
        <kernel-team@fb.com>
To: Alexei Starovoitov <ast@fb.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([45.249.212.189]:4933 "EHLO
        dggrg03-dlp.huawei.com" rhost-flags-OK-FAIL-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751394AbdCaHtw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 31 Mar 2017 03:49:52 -0400
In-Reply-To: <20170331044543.4075183-4-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Alexei,

Please see the patch I sent. Since we export bpf_program__set_type(),
bpf_program__set_xxx() should be built based on it.

Thank you.

On 2017/3/31 12:45, Alexei Starovoitov wrote:
> expose bpf_program__set_type() to set program type
>
> Signed-off-by: Alexei Starovoitov <ast@kernel.org>
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>
> Acked-by: Martin KaFai Lau <kafai@fb.com>
> ---
>   
