From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] skb: avoid unnecessary reallocations in __skb_cow
Date: Tue, 29 May 2012 15:43:00 +0200
Message-ID: <1338298980.2840.32.camel@edumazet-glaptop>
References: <1338298508-40376-1-git-send-email-nbd@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Felix Fietkau <nbd@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:64808 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752065Ab2E2NnG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 May 2012 09:43:06 -0400
Received: by eaak11 with SMTP id k11so1069566eaa.19
        for <netdev@vger.kernel.org>; Tue, 29 May 2012 06:43:04 -0700 (PDT)
In-Reply-To: <1338298508-40376-1-git-send-email-nbd@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-05-29 at 15:35 +0200, Felix Fietkau wrote:

> 
> Signed-off-by: Felix Fietkau <nbd@openwrt.org>
> ---
>  include/linux/skbuff.h |    2 --
>  1 files changed, 0 insertions(+), 2 deletions(-)
> 

 

Signed-off-by: Eric Dumazet <edumazet@google.com>

Thanks !
