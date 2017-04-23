From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next] bpf, doc: update list of architectures that
 do eBPF JIT
Date: Sun, 23 Apr 2017 19:39:40 +0200
Message-ID: <58FCE6DC.1030304@iogearbox.net>
References: <20170423160100.1155435-1-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Alexei Starovoitov <ast@fb.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:55573 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1162600AbdDWRjt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 23 Apr 2017 13:39:49 -0400
In-Reply-To: <20170423160100.1155435-1-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/23/2017 06:01 PM, Alexei Starovoitov wrote:
> update the list and remove 'in the future' statement,
> since all still alive 64-bit architectures now do eBPF JIT.
>
> Signed-off-by: Alexei Starovoitov <ast@kernel.org>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>

> mips64 is the only 'still alive' 64-bit arch without eBPF JIT :)

(... and work in progress by cavium folks. ;))
