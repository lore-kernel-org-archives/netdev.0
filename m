From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [Patch net-next] ipv6: remove unused function ipv6_inherit_linklocal()
Date: Mon, 05 May 2014 11:27:10 +0200
Message-ID: <5367596E.7060502@6wind.com>
References: <1399076461-12172-1-git-send-email-xiyou.wangcong@gmail.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:55496 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755458AbaEEJ1N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2014 05:27:13 -0400
Received: by mail-wi0-f172.google.com with SMTP id hi2so1021673wib.17
        for <netdev@vger.kernel.org>; Mon, 05 May 2014 02:27:12 -0700 (PDT)
In-Reply-To: <1399076461-12172-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 03/05/2014 02:21, Cong Wang a =C3=A9crit :
> It is no longer used after commit e837735ec406a347756e
> (ip6_tunnel: ensure to always have a link local address).
>
> Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
Acked-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
