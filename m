From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH net-next] bpf, doc: Add arm32 as arch supporting eBPF JIT
Date: Wed, 23 Aug 2017 09:55:14 -0700
Message-ID: <3f9982db-ea0a-dc2a-99d0-3d147f48a591@fb.com>
References: <1503503950-5146-1-git-send-email-illusionist.neo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <daniel@iogearbox.net>
To: Shubham Bansal <illusionist.neo@gmail.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:34417 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932297AbdHWQzi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2017 12:55:38 -0400
In-Reply-To: <1503503950-5146-1-git-send-email-illusionist.neo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/23/17 8:59 AM, Shubham Bansal wrote:
> As eBPF JIT support for arm32 was added recently with
> commit 39c13c204bb1150d401e27d41a9d8b332be47c49, it seems appropriate to
> add arm32 as arch with support for eBPF JIT in bpf and sysctl docs as well.
>
> Signed-off-by: Shubham Bansal <illusionist.neo@gmail.com>

Acked-by: Alexei Starovoitov <ast@kernel.org>
