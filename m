From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH v2 4/6] netns ct: per-netns	net.netfilter.nf_conntrack_checksum
 sysctl
Date: Thu, 02 Oct 2008 10:02:25 +0200
Message-ID: <48E48011.90709@trash.net>
References: <48C01046.2070704@trash.net> <1220842990-30500-17-git-send-email-adobriyan@gmail.com> <48C623CA.9060803@trash.net> <20080909073245.GA7307@x200.localdomain> <48C62B1C.7070104@trash.net> <20080913105239.GE7440@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	containers@lists.linux-foundation.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:50963 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752744AbYJBID0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2008 04:03:26 -0400
In-Reply-To: <20080913105239.GE7440@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alexey Dobriyan wrote:
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
> ---
>
>  include/net/netfilter/nf_conntrack.h           |    1 -
>  include/net/netns/conntrack.h                  |    1 +
>  net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |    2 +-
>  net/ipv4/netfilter/nf_conntrack_proto_icmp.c   |    2 +-
>  net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c |    2 +-
>  net/netfilter/nf_conntrack_proto_dccp.c        |    2 +-
>  net/netfilter/nf_conntrack_proto_tcp.c         |    2 +-
>  net/netfilter/nf_conntrack_proto_udp.c         |    2 +-
>  net/netfilter/nf_conntrack_proto_udplite.c     |    2 +-
>  net/netfilter/nf_conntrack_standalone.c        |    7 +++----

Applied.


