From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [Patch net-next] ipv6: use ipv6_addr_any() helper
Date: Wed, 22 May 2013 18:06:38 +0200
Message-ID: <519CED0E.9050708@6wind.com>
References: <1369237266-21742-1-git-send-email-xiyou.wangcong@gmail.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f169.google.com ([74.125.82.169]:54801 "EHLO
	mail-we0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750956Ab3EVQGo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 May 2013 12:06:44 -0400
Received: by mail-we0-f169.google.com with SMTP id q55so1423512wes.0
        for <netdev@vger.kernel.org>; Wed, 22 May 2013 09:06:43 -0700 (PDT)
In-Reply-To: <1369237266-21742-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 22/05/2013 17:41, Cong Wang a =C3=A9crit :
> From: Cong Wang <xiyou.wangcong@gmail.com>
>
> ipv6_addr_any() is a faster way to determine if an addr
> is ipv6 any addr, no need to compute the addr type.
>
> Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
>
Acked-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
