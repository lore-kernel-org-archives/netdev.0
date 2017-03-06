From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net] bpf: add get_next_key callback to LPM map
Date: Mon, 06 Mar 2017 10:30:22 +0100
Message-ID: <58BD2C2E.3070106@iogearbox.net>
References: <1488735668-2296008-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Mack <daniel@zonque.org>,
        Dmitry Vyukov <dvyukov@google.com>, netdev@vger.kernel.org
To: Alexei Starovoitov <ast@fb.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:41918 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753043AbdCFJab (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Mar 2017 04:30:31 -0500
In-Reply-To: <1488735668-2296008-1-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/05/2017 06:41 PM, Alexei Starovoitov wrote:
> map_get_next_key callback is mandatory. Supply dummy handler.
>
> Fixes: b95a5c4db09b ("bpf: add a longest prefix match trie map implementation")
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Signed-off-by: Alexei Starovoitov <ast@kernel.org>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
