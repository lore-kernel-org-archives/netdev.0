From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] bpf: Changes needed (or desired) for MIPS support
Date: Wed, 14 Jun 2017 15:03:57 -0400 (EDT)
Message-ID: <20170614.150357.632035401955794047.davem@davemloft.net>
References: <20170613234938.4823-1-david.daney@cavium.com>
        <594081CA.3060801@iogearbox.net>
        <e17ffbca-f11f-5617-3188-a7eb82b03ed3@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, david.daney@cavium.com, ast@kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-mips@linux-mips.org, ralf@linux-mips.org
To: ddaney@caviumnetworks.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <e17ffbca-f11f-5617-3188-a7eb82b03ed3@caviumnetworks.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Daney <ddaney@caviumnetworks.com>
Date: Wed, 14 Jun 2017 08:54:03 -0700

> On 06/13/2017 05:22 PM, Daniel Borkmann wrote:
>> On 06/14/2017 01:49 AM, David Daney wrote:
>>> This is a grab bag of changes to the bpf testing infrastructure I
>>> developed working on MIPS eBPF JIT support.  The change to
>>> bpf_jit_disasm is probably universally beneficial, the others are more
>>> MIPS specific.
>> I think these could go independently through net-next tree?
> 
> Yes, if davem is happy with them, I think that makes sense that he
> take them via net-next.

Series applied to net-next, thanks!
