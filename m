From: David Shwatrz <dshwatrz@gmail.com>
Subject: Re: [PATCH net-next-2.6] Documentation/networking/l2tp.txt: update documentation.
Date: Thu, 16 Dec 2010 20:22:44 +0200
Message-ID: <AANLkTi=W2ZbdRnH=TnwW2qOW+s31izUN=VE9GGf+oVO9@mail.gmail.com>
References: <AANLkTimhKtb+p6-4bG7QXBmUZ5YX=m5u1ZkxEb94e1K1@mail.gmail.com>
	<20101215105207.29b1a837@nehalam>
	<20101215.111448.104060252.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: shemminger@vyatta.com, netdev@vger.kernel.org, jchapman@katalix.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f171.google.com ([209.85.215.171]:49895 "EHLO
	mail-ey0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756184Ab0LPSWq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Dec 2010 13:22:46 -0500
Received: by eyg5 with SMTP id 5so2140262eyg.2
        for <netdev@vger.kernel.org>; Thu, 16 Dec 2010 10:22:45 -0800 (PST)
In-Reply-To: <20101215.111448.104060252.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
My intention was just to fix the documentation so it will reflect
the current situation, where you cannot use "ip l2tp", but there
is an alternative (though temporary probably). It could take
time till this will be available in iproute2. That's all.

DS



On Wed, Dec 15, 2010 at 9:14 PM, David Miller <davem@davemloft.net> wrote:
> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Wed, 15 Dec 2010 10:52:07 -0800
>
>> I wish you would stop whining about it and just reimplement
>> without using libnl as requested.
>
> Seriously.
>
> David, I'm not applying a patch where you complain about
> a problem which you have self-inflicted upon yourself.
>
> Stephen's request was beyond reasonable, and you're just
> being unnecessarily difficult.
>
