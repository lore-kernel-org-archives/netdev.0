From: Michael Ellerman <patch-notifications@ellerman.id.au>
Subject: Re: [1/3] powerpc: bpf: remove redundant check for non-null image
Date: Fri, 27 Jan 2017 11:40:33 +1100 (AEDT)
Message-ID: <3v8g1Y0Dnjz9t1Q@ozlabs.org>
References: <e73efe6facf6c06932b4a87707e5978172ee773e.1484326337.git.naveen.n.rao@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
        davem@davemloft.net, daniel@iogearbox.net, ast@fb.com
To: "Naveen N. Rao" <naveen.n.rao@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([103.22.144.67]:55091 "EHLO ozlabs.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750749AbdA0AlM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 26 Jan 2017 19:41:12 -0500
In-Reply-To: <e73efe6facf6c06932b4a87707e5978172ee773e.1484326337.git.naveen.n.rao@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-01-13 at 17:10:00 UTC, "Naveen N. Rao" wrote:
> From: Daniel Borkmann <daniel@iogearbox.net>
> 
> We have a check earlier to ensure we don't proceed if image is NULL. As
> such, the redundant check can be removed.
> 
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> [Added similar changes for classic BPF JIT]
> Signed-off-by: Naveen N. Rao <naveen.n.rao@linux.vnet.ibm.com>
> Acked-by: Alexei Starovoitov <ast@kernel.org>

Applied to powerpc next, thanks.

https://git.kernel.org/powerpc/c/052de33ca4f840bf35587eacdf78b3

cheers
