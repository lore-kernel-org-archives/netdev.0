From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 5/5] net: Export inet_offloads and
 inet6_offloads
Date: Mon, 08 Sep 2014 03:42:33 -0700
Message-ID: <1410172953.11872.89.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1410153989-23837-1-git-send-email-therbert@google.com>
	 <1410153989-23837-6-git-send-email-therbert@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:43592 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752784AbaIHKmf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2014 06:42:35 -0400
Received: by mail-pa0-f46.google.com with SMTP id eu11so27135394pac.19
        for <netdev@vger.kernel.org>; Mon, 08 Sep 2014 03:42:35 -0700 (PDT)
In-Reply-To: <1410153989-23837-6-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2014-09-07 at 22:26 -0700, Tom Herbert wrote:
> Want to be able to call this in foo-over-udp offloads, etc.
> 
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---
>  net/ipv4/protocol.c | 1 +
>  net/ipv6/protocol.c | 1 +
>  2 files changed, 2 insertions(+)

This should not be last patch of this serie, but added in a later serie
when really needed.
