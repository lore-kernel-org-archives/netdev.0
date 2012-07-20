From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: Return bool instead of int where
 appropriate
Date: Fri, 20 Jul 2012 10:02:57 +0200
Message-ID: <1342771377.2626.6102.camel@edumazet-glaptop>
References: <1342769538-4039-1-git-send-email-subramanian.vijay@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Vijay Subramanian <subramanian.vijay@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:58932 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750909Ab2GTIDD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2012 04:03:03 -0400
Received: by bkwj10 with SMTP id j10so3111727bkw.19
        for <netdev@vger.kernel.org>; Fri, 20 Jul 2012 01:03:01 -0700 (PDT)
In-Reply-To: <1342769538-4039-1-git-send-email-subramanian.vijay@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-07-20 at 00:32 -0700, Vijay Subramanian wrote:
> Applied to a set of static inline functions in tcp_input.c
> 
> Signed-off-by: Vijay Subramanian <subramanian.vijay@gmail.com>
> ---
>  net/ipv4/tcp_input.c |   16 ++++++++--------
>  1 files changed, 8 insertions(+), 8 deletions(-)

Acked-by: Eric Dumazet <edumazet@google.com>
