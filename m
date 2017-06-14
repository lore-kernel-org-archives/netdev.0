From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH 1/4] tools: bpf_jit_disasm:  Handle large images.
Date: Wed, 14 Jun 2017 02:19:52 +0200
Message-ID: <59408128.7010208@iogearbox.net>
References: <20170613234938.4823-1-david.daney@cavium.com> <20170613234938.4823-2-david.daney@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-mips@linux-mips.org, ralf@linux-mips.org
To: David Daney <david.daney@cavium.com>,
        Alexei Starovoitov <ast@kernel.org>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170613234938.4823-2-david.daney@cavium.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/14/2017 01:49 AM, David Daney wrote:
> Dynamically allocate memory so that JIT images larger than the size of
> the statically allocated array can be handled.
>
> Signed-off-by: David Daney <david.daney@cavium.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
