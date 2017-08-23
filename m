From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next] bpf, doc: Add arm32 as arch supporting eBPF
 JIT
Date: Wed, 23 Aug 2017 19:03:15 +0200
Message-ID: <599DB553.4060609@iogearbox.net>
References: <1503503950-5146-1-git-send-email-illusionist.neo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ast@fb.com
To: Shubham Bansal <illusionist.neo@gmail.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:41703 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754150AbdHWRDT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2017 13:03:19 -0400
In-Reply-To: <1503503950-5146-1-git-send-email-illusionist.neo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/23/2017 05:59 PM, Shubham Bansal wrote:
> As eBPF JIT support for arm32 was added recently with
> commit 39c13c204bb1150d401e27d41a9d8b332be47c49, it seems appropriate to
> add arm32 as arch with support for eBPF JIT in bpf and sysctl docs as well.
>
> Signed-off-by: Shubham Bansal <illusionist.neo@gmail.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
