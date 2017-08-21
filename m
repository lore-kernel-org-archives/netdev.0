From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH net] bpf, doc: also add s390x as arch to sysctl
 description
Date: Sun, 20 Aug 2017 17:31:23 -0700
Message-ID: <b723b57d-00d7-0ee3-6e0e-3d499721122d@fb.com>
References: <23b5525b786a641eb777cf44839fd98189d27acb.1503267753.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:58963 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753414AbdHUAcI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 20 Aug 2017 20:32:08 -0400
In-Reply-To: <23b5525b786a641eb777cf44839fd98189d27acb.1503267753.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/20/17 3:26 PM, Daniel Borkmann wrote:
> Looks like this was accidentally missed, so still add s390x
> as supported eBPF JIT arch to bpf_jit_enable.
>
> Fixes: 014cd0a368dc ("bpf: Update sysctl documentation to list all supported architectures")
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Acked-by: Alexei Starovoitov <ast@kernel.org>
