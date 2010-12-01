From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: multi bpf filter will impact performance?
Date: Wed, 1 Dec 2010 15:59:47 +0800
Message-ID: <AANLkTinQ9c_C6LzNf5c3BbJXQTVKmbqf6KR9K23tGETw@mail.gmail.com>
References: <AANLkTikx68M43+vv+Rav_HCJMJnuc15TtuBgmbv2xP=U@mail.gmail.com>
 <1291109699.2904.11.camel@edumazet-laptop> <AANLkTi=VpmnrXTBNV7McQm6mq9ULT7KTKbM8_hLPoL=2@mail.gmail.com>
 <1291127670.2904.96.camel@edumazet-laptop> <AANLkTi=-iuGJDzELJpu26KtKr77uDx0xNCc8ibEidJ4h@mail.gmail.com>
 <AANLkTimynbhgo2dqFwKOc8NT9TXpkCtCJMvwkySEBORz@mail.gmail.com> <1291189649.2856.478.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Rui <wirelesser@gmail.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:55465 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753277Ab0LAIAI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Dec 2010 03:00:08 -0500
Received: by fxm8 with SMTP id 8so1960614fxm.19
        for <netdev@vger.kernel.org>; Wed, 01 Dec 2010 00:00:07 -0800 (PST)
In-Reply-To: <1291189649.2856.478.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 1, 2010 at 3:47 PM, Eric Dumazet <eric.dumazet@gmail.com> w=
rote:
> Le mercredi 01 d=E9cembre 2010 =E0 15:36 +0800, Changli Gao a =E9crit=
 :
>
> Oh well, it seems you read over my neck, I was preparing a patch with
> SKF_AD_RXHASH and SKF_AD_CPU
>
>

Nice to hear it. :)

There are too many filters: bpf, iptables and tc. Maybe an unified one
such as nft is needed. Then the duplicate code would be reduced. Maybe
it is just a good dream.

--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
