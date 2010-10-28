From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ip_gre: fix percpu stats accounting
Date: Thu, 28 Oct 2010 20:47:59 +0200
Message-ID: <1288291679.2711.1.camel@edumazet-laptop>
References: <1288283634.11523.20.camel@edumazet-laptop>
	 <20101028.102917.246527148.davem@davemloft.net>
	 <1288291138.2711.0.camel@edumazet-laptop>
	 <20101028.114102.112602886.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: xemul@parallels.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:54140 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757796Ab0J1SsF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Oct 2010 14:48:05 -0400
Received: by wyf28 with SMTP id 28so2266966wyf.19
        for <netdev@vger.kernel.org>; Thu, 28 Oct 2010 11:48:03 -0700 (PDT)
In-Reply-To: <20101028.114102.112602886.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 28 octobre 2010 =C3=A0 11:41 -0700, David Miller a =C3=A9crit =
:
> I am still able to revert this I think without screwing up
> publicly visible history, so I will double check and do the
> revert if I can.

Cool, I'll provide a patch in a couple of minutes, when tested.

Thanks


