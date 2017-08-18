From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH v2] bpf: Update sysctl documentation to list all supported architectures
Date: Fri, 18 Aug 2017 11:27:07 +1000
Message-ID: <87efs9r7h0.fsf@concordia.ellerman.id.au>
References: <1502965839-23115-1-git-send-email-mpe@ellerman.id.au> <59958304.7030702@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>, ast@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <59958304.7030702@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Daniel Borkmann <daniel@iogearbox.net> writes:

> On 08/17/2017 12:30 PM, Michael Ellerman wrote:
>> The sysctl documentation states that the JIT is only available on
>> x86_64, which is no longer correct.
>>
>> Update the list, and break it out to indicate which architectures
>> support the cBPF JIT (via HAVE_CBPF_JIT) or the eBPF JIT
>> (HAVE_EBPF_JIT).
>>
>> Signed-off-by: Michael Ellerman <mpe@ellerman.id.au>
>
> The last paragraph speaking about tcpdump, I can take care of
> later, also given the patch is about updating list of archs, so
> lgtm, thanks!

Thanks.

cheers
