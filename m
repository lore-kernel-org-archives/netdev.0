From: Quentin Monnet <quentin.monnet@netronome.com>
Subject: Re: [PATCH net-next V2 1/3] tools: bpftool: open pinned object
 without type check
Date: Thu, 2 Nov 2017 10:50:02 +0000
Message-ID: <8a0b1fad-d338-3cbd-bbc3-e4b2054fbee1@netronome.com>
References: <20171102075917.2780-1-bhole_prashant_q7@lab.ntt.co.jp>
 <20171102075917.2780-2-bhole_prashant_q7@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: Prashant Bhole <bhole_prashant_q7@lab.ntt.co.jp>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:47767 "EHLO
        mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752614AbdKBKuF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Nov 2017 06:50:05 -0400
Received: by mail-wm0-f50.google.com with SMTP id r196so10105742wmf.2
        for <netdev@vger.kernel.org>; Thu, 02 Nov 2017 03:50:05 -0700 (PDT)
In-Reply-To: <20171102075917.2780-2-bhole_prashant_q7@lab.ntt.co.jp>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2017-11-02 16:59 UTC+0900 ~ Prashant Bhole <bhole_prashant_q7@lab.ntt.co.jp>
> This was needed for opening any file in bpf-fs without knowing
> its object type
> 
> Signed-off-by: Prashant Bhole <bhole_prashant_q7@lab.ntt.co.jp>

Acked-by: Quentin Monnet <quentin.monnet@netronome.com>
