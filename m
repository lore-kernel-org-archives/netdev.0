From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v2] bpf: Update sysctl documentation to list all supported
 architectures
Date: Thu, 17 Aug 2017 13:50:28 +0200
Message-ID: <59958304.7030702@iogearbox.net>
References: <1502965839-23115-1-git-send-email-mpe@ellerman.id.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Michael Ellerman <mpe@ellerman.id.au>, ast@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1502965839-23115-1-git-send-email-mpe@ellerman.id.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/17/2017 12:30 PM, Michael Ellerman wrote:
> The sysctl documentation states that the JIT is only available on
> x86_64, which is no longer correct.
>
> Update the list, and break it out to indicate which architectures
> support the cBPF JIT (via HAVE_CBPF_JIT) or the eBPF JIT
> (HAVE_EBPF_JIT).
>
> Signed-off-by: Michael Ellerman <mpe@ellerman.id.au>

The last paragraph speaking about tcpdump, I can take care of
later, also given the patch is about updating list of archs, so
lgtm, thanks!

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
