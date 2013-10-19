From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 0/6] net: Implement GSO/TSO support for IPIP
Date: Sat, 19 Oct 2013 11:59:18 -0700
Message-ID: <1382209158.3284.47.camel@edumazet-glaptop.roam.corp.google.com>
References: <1382208178-22347-1-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Jerry Chu <hkchu@google.com>, Tom Herbert <therbert@google.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f44.google.com ([209.85.160.44]:46133 "EHLO
	mail-pb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750901Ab3JSS7U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Oct 2013 14:59:20 -0400
Received: by mail-pb0-f44.google.com with SMTP id xa7so5216202pbc.17
        for <netdev@vger.kernel.org>; Sat, 19 Oct 2013 11:59:19 -0700 (PDT)
In-Reply-To: <1382208178-22347-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-10-19 at 11:42 -0700, Eric Dumazet wrote:
> This patch serie implements GSO/TSO support for IPIP
> 
> David, please note it applies after "ipv4: gso: send_check() & segment() cleanups"
> ( http://patchwork.ozlabs.org/patch/284714/ )

Oh well, I meant to say the above patch was _included_ in this patch
set.
