From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH v2 6/6] netns ct: per-netns conntrack accounting
Date: Thu, 02 Oct 2008 10:06:45 +0200
Message-ID: <48E48115.9040605@trash.net>
References: <48C01046.2070704@trash.net> <1220842990-30500-17-git-send-email-adobriyan@gmail.com> <48C623CA.9060803@trash.net> <20080909073245.GA7307@x200.localdomain> <48C62B1C.7070104@trash.net> <20080913105509.GG7440@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	containers@lists.linux-foundation.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:51047 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752277AbYJBIHp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2008 04:07:45 -0400
In-Reply-To: <20080913105509.GG7440@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alexey Dobriyan wrote:
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
> ---
>
>  include/net/netfilter/nf_conntrack_acct.h |   10 +--
>  include/net/netns/conntrack.h             |    2 
>  net/netfilter/nf_conntrack_acct.c         |  100 +++++++++++++++++++++---------
>  net/netfilter/nf_conntrack_core.c         |    4 -
>  4 files changed, 81 insertions(+), 35 deletions(-)
>   
Applied.

