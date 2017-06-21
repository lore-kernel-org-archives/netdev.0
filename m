From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH iproute2 net-next] bpf: Add support for IFLA_XDP_PROG_ID
Date: Wed, 21 Jun 2017 23:35:27 +0200
Message-ID: <594AE69F.1010000@iogearbox.net>
References: <20170621212942.2333878-1-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@fb.com>, davem@davemloft.net,
        netdev@vger.kernel.org
To: Martin KaFai Lau <kafai@fb.com>, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:59822 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751835AbdFUVff (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Jun 2017 17:35:35 -0400
In-Reply-To: <20170621212942.2333878-1-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/21/2017 11:29 PM, Martin KaFai Lau wrote:
> This patch adds support to the newly added IFLA_XDP_PROG_ID.
>
> ./ip link show dev eth0
> 3: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 xdpgeneric/id:2 qdisc [...]
>
> Signed-off-by: Martin KaFai Lau <kafai@fb.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
