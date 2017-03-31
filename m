From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH net-next 1/6] bpf: introduce BPF_PROG_TEST_RUN command
Date: Thu, 30 Mar 2017 19:57:57 -0700
Message-ID: <d8c30545-b247-6831-41cc-a546404d6b0a@fb.com>
References: <20170331013157.3298003-1-ast@fb.com>
 <20170331013157.3298003-2-ast@fb.com>
 <9105ab34-8fee-fab4-96fe-3bfe7f3a84b7@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Martin KaFai Lau <kafai@fb.com>, <netdev@vger.kernel.org>,
        <kernel-team@fb.com>
To: "Wangnan (F)" <wangnan0@huawei.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:35537 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752517AbdCaC6c (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 30 Mar 2017 22:58:32 -0400
In-Reply-To: <9105ab34-8fee-fab4-96fe-3bfe7f3a84b7@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/30/17 7:53 PM, Wangnan (F) wrote:
> I suggest using a CONFIG option to enable/disable code in
> test_run.o to reduce attack plane.

attack plane? what attack do you see and how config helps?
