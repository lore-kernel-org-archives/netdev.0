From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH net-next 0/3] Misc BPF cleanup
Date: Mon, 24 Apr 2017 07:45:31 -0700
Message-ID: <87a7f6f9-2f52-dea4-0319-1133bb2132b3@fb.com>
References: <20170424133108.31595-1-alexander@alemayhu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <daniel@iogearbox.net>
To: Alexander Alemayhu <alexander@alemayhu.com>,
        <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:45193 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1172886AbdDXOpx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 10:45:53 -0400
In-Reply-To: <20170424133108.31595-1-alexander@alemayhu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/24/17 6:31 AM, Alexander Alemayhu wrote:
> Hei,
>
> while looking into making the Makefile in samples/bpf better handle O= I saw
> several warnings when running `make clean && make samples/bpf/`. This series
> reduces those warnings.

Cleanup looks good to me.
Acked-by: Alexei Starovoitov <ast@kernel.org>
