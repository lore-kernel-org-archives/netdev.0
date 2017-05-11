From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH 4/5] bpf: Add bpf_verify_program() to the library.
Date: Thu, 11 May 2017 14:54:51 +0200
Message-ID: <59145F1B.8060209@iogearbox.net>
References: <20170510.151000.1271350336586950089.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:47405 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932708AbdEKMyz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 11 May 2017 08:54:55 -0400
In-Reply-To: <20170510.151000.1271350336586950089.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/10/2017 09:10 PM, David Miller wrote:
>
> This allows a test case to load a BPF program and unconditionally
> acquire the verifier log.
>
> It also allows specification of the strict alignment flag.
>
> Signed-off-by: David S. Miller <davem@davemloft.net>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
