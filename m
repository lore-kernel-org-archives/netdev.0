From: Daniel Baluta <daniel.baluta@gmail.com>
Subject: Re: [PATCH] tcp: disallow bind() to reuse addr/port
Date: Tue, 11 Jan 2011 15:04:00 +0200
Message-ID: <AANLkTi=0MJjcqLJT2KF6z01tPrUMcUm6ZQ_MWyfFpbvC@mail.gmail.com>
References: <AANLkTimrpZOWEc5qXPEbrJbt2Nmh2vY69aC1Dwf1cCPH@mail.gmail.com>
	<AANLkTinNcds1EAnWXOX6wAjg+wv4O=Xd65hHEGWoGos8@mail.gmail.com>
	<1294140172.3579.81.camel@edumazet-laptop>
	<AANLkTimuNM7vmeR89WKXtrUbJO1Wt1ivp9y=bQvtWg0j@mail.gmail.com>
	<1294744462.2927.53.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Gaspar Chilingarov <gasparch@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f66.google.com ([209.85.210.66]:53267 "EHLO
	mail-pz0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753937Ab1AKNEA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Jan 2011 08:04:00 -0500
Received: by pzk36 with SMTP id 36so1763755pzk.1
        for <netdev@vger.kernel.org>; Tue, 11 Jan 2011 05:04:00 -0800 (PST)
In-Reply-To: <1294744462.2927.53.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 11, 2011 at 1:14 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le mercredi 05 janvier 2011 =E0 11:00 +0200, Daniel Baluta a =E9crit =
:
>
>> Going back to my first email, are there any follow ups on your
>> "tcp: bind() fix when many ports are bound" patch. I've searched
>> netdev archives but no luck. I might have missed something.
>>
>> I really appreciate your help.
>>
>
> I believe following patch should solve the problem.

I have tested the patch and it works.

>
> Thanks for reminding us this issue !

thanks,
Daniel.
