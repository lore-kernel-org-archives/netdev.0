From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [net-next 2/2] ip6_tunnel: allow to change mode for the ip6tnl0
Date: Tue, 21 Oct 2014 17:13:16 +0200
Message-ID: <5446780C.7070004@6wind.com>
References: <1413879088-13513-1-git-send-email-alan@al-an.info> <1413879088-13513-2-git-send-email-alan@al-an.info>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>
To: Alexey Andriyanov <alan@al-an.info>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:41995 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755015AbaJUPNX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Oct 2014 11:13:23 -0400
Received: by mail-wi0-f170.google.com with SMTP id hi2so11323867wib.1
        for <netdev@vger.kernel.org>; Tue, 21 Oct 2014 08:13:20 -0700 (PDT)
In-Reply-To: <1413879088-13513-2-git-send-email-alan@al-an.info>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 21/10/2014 10:11, Alexey Andriyanov a =C3=A9crit :
> The fallback device is in ipv6 mode by default.
After patch 1/2, this is not true. Am I missing something?
