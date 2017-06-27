From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 net-next] bpf: Add support for IFLA_XDP_PROG_ID
Date: Tue, 27 Jun 2017 16:14:55 -0700
Message-ID: <20170627161455.06528a2c@xeon-e3>
References: <20170621212942.2333878-1-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Alexei Starovoitov <ast@fb.com>, <davem@davemloft.net>,
        <netdev@vger.kernel.org>
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:34764 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753830AbdF0XPD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Jun 2017 19:15:03 -0400
Received: by mail-pg0-f50.google.com with SMTP id t186so22646323pgb.1
        for <netdev@vger.kernel.org>; Tue, 27 Jun 2017 16:15:02 -0700 (PDT)
In-Reply-To: <20170621212942.2333878-1-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 21 Jun 2017 14:29:42 -0700
Martin KaFai Lau <kafai@fb.com> wrote:

> This patch adds support to the newly added IFLA_XDP_PROG_ID.
> 
> ./ip link show dev eth0
> 3: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 xdpgeneric/id:2 qdisc [...]
> 
> Signed-off-by: Martin KaFai Lau <kafai@fb.com>

Applied to net-next
