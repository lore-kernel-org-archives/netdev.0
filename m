From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH iproute2] tc: bpf: add ppc64 and sparc64 to list of archs
 with eBPF support
Date: Sun, 07 May 2017 17:20:48 +0200
Message-ID: <590F3B50.4060408@iogearbox.net>
References: <1494102610-19853-1-git-send-email-alexander@alemayhu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org
To: Alexander Alemayhu <alexander@alemayhu.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:54704 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751018AbdEGWmB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 7 May 2017 18:42:01 -0400
In-Reply-To: <1494102610-19853-1-git-send-email-alexander@alemayhu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/06/2017 10:30 PM, Alexander Alemayhu wrote:
> sparc64 support was added in 7a12b5031c6b (sparc64: Add eBPF JIT., 2017-04-17)[0]
> and ppc64 in 156d0e290e96 (powerpc/ebpf/jit: Implement JIT compiler for extended BPF, 2016-06-22)[1].
>
> [0]: https://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git/commit/?id=7a12b5031c6b
> [1]: https://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git/commit/?id=156d0e290e96
> Signed-off-by: Alexander Alemayhu <alexander@alemayhu.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
