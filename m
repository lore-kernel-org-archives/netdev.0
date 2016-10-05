From: Michael Ellerman <patch-notifications@ellerman.id.au>
Subject: Re: [1/3] bpf powerpc: introduce accessors for using the tmp local stack space
Date: Wed,  5 Oct 2016 13:36:24 +1100 (AEDT)
Message-ID: <3spfzs0whCz9rxw@ozlabs.org>
References: <40b65ab2bb3a48837ab047a70887de3ccd70c56b.1474661927.git.naveen.n.rao@linux.vnet.ibm.com>
Cc: Ananth N Mavinakayanahalli <ananth@in.ibm.com>,
        "David S. Miller" <davem@davemloft.net>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Alexei Starovoitov <ast@fb.com>
To: "Naveen N. Rao" <naveen.n.rao@linux.vnet.ibm.com>,
        linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <40b65ab2bb3a48837ab047a70887de3ccd70c56b.1474661927.git.naveen.n.rao@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2016-23-09 at 20:35:00 UTC, "Naveen N. Rao" wrote:
> While at it, ensure that the location of the local save area is
> consistent whether or not we setup our own stackframe. This property is
> utilised in the next patch that adds support for tail calls.
> 
> Signed-off-by: Naveen N. Rao <naveen.n.rao@linux.vnet.ibm.com>

Series applied to powerpc next, thanks.

https://git.kernel.org/powerpc/c/7b847f523fe07b4ad73a01cec49a4d

cheers
