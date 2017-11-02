From: Quentin Monnet <quentin.monnet@netronome.com>
Subject: Re: [PATCH net-next V2 3/3] tools: bpftool: optionally show filenames
 of pinned objects
Date: Thu, 2 Nov 2017 10:51:10 +0000
Message-ID: <6e7314a0-ff85-ef49-4cf3-b57f9738a1a8@netronome.com>
References: <20171102075917.2780-1-bhole_prashant_q7@lab.ntt.co.jp>
 <20171102075917.2780-4-bhole_prashant_q7@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: Prashant Bhole <bhole_prashant_q7@lab.ntt.co.jp>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:45451 "EHLO
        mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752780AbdKBKvN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Nov 2017 06:51:13 -0400
Received: by mail-wm0-f46.google.com with SMTP id y80so10091453wmd.0
        for <netdev@vger.kernel.org>; Thu, 02 Nov 2017 03:51:12 -0700 (PDT)
In-Reply-To: <20171102075917.2780-4-bhole_prashant_q7@lab.ntt.co.jp>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2017-11-02 16:59 UTC+0900 ~ Prashant Bhole <bhole_prashant_q7@lab.ntt.co.jp>
> Making it optional to show file names of pinned objects because
> it scans complete bpf-fs filesystem which is costly.
> Added option -f|--bpffs. Documentation updated.
> 
> Signed-off-by: Prashant Bhole <bhole_prashant_q7@lab.ntt.co.jp>
> ---
> v2:
>  - Change command line option from {-l|--pinned} to {-f|--bpffs}
>  - Updated documentation

Acked-by: Quentin Monnet <quentin.monnet@netronome.com>
