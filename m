From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] bpf: Update sysctl documentation to list all
 supported architectures
Date: Thu, 17 Aug 2017 10:09:52 -0700 (PDT)
Message-ID: <20170817.100952.216038410685469125.davem@davemloft.net>
References: <1502965839-23115-1-git-send-email-mpe@ellerman.id.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@kernel.org, daniel@iogearbox.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: mpe@ellerman.id.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1502965839-23115-1-git-send-email-mpe@ellerman.id.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michael Ellerman <mpe@ellerman.id.au>
Date: Thu, 17 Aug 2017 20:30:39 +1000

> The sysctl documentation states that the JIT is only available on
> x86_64, which is no longer correct.
> 
> Update the list, and break it out to indicate which architectures
> support the cBPF JIT (via HAVE_CBPF_JIT) or the eBPF JIT
> (HAVE_EBPF_JIT).
> 
> Signed-off-by: Michael Ellerman <mpe@ellerman.id.au>

Applied, thanks Michael.
