From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next] lwt_bpf: bpf_lwt_prog_cmp() can be static
Date: Thu, 12 Jan 2017 15:42:14 +0100
Message-ID: <587795C6.4060204@iogearbox.net>
References: <20170112143928.21496-1-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <weiyongjun1@huawei.com>, netdev@vger.kernel.org
To: Wei Yongjun <weiyj.lk@gmail.com>,
        "David S . Miller" <davem@davemloft.net>,
        Thomas Graf <tgraf@suug.ch>,
        Alexei Starovoitov <ast@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:41862 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750720AbdALOmX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 09:42:23 -0500
In-Reply-To: <20170112143928.21496-1-weiyj.lk@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/12/2017 03:39 PM, Wei Yongjun wrote:
> From: Wei Yongjun <weiyongjun1@huawei.com>
>
> Fixes the following sparse warning:
>
> net/core/lwt_bpf.c:355:5: warning:
>   symbol 'bpf_lwt_prog_cmp' was not declared. Should it be static?
>
> Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
