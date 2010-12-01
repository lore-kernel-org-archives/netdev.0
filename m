From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: multi bpf filter will impact performance?
Date: Wed, 1 Dec 2010 16:15:00 +0800
Message-ID: <AANLkTin6d=t6U28A-r=FznqE+5QuGXwg1tStOw-JXabg@mail.gmail.com>
References: <AANLkTikx68M43+vv+Rav_HCJMJnuc15TtuBgmbv2xP=U@mail.gmail.com>
 <1291109699.2904.11.camel@edumazet-laptop> <AANLkTi=VpmnrXTBNV7McQm6mq9ULT7KTKbM8_hLPoL=2@mail.gmail.com>
 <1291127670.2904.96.camel@edumazet-laptop> <AANLkTi=-iuGJDzELJpu26KtKr77uDx0xNCc8ibEidJ4h@mail.gmail.com>
 <AANLkTimynbhgo2dqFwKOc8NT9TXpkCtCJMvwkySEBORz@mail.gmail.com>
 <1291189649.2856.478.camel@edumazet-laptop> <AANLkTinQ9c_C6LzNf5c3BbJXQTVKmbqf6KR9K23tGETw@mail.gmail.com>
 <1291190956.2856.485.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Rui <wirelesser@gmail.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:62448 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752884Ab0LAIPY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Dec 2010 03:15:24 -0500
Received: by fxm8 with SMTP id 8so1969845fxm.19
        for <netdev@vger.kernel.org>; Wed, 01 Dec 2010 00:15:23 -0800 (PST)
In-Reply-To: <1291190956.2856.485.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 1, 2010 at 4:09 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> A dream would be to have a native compiler, and not interpret pseudo
> code...
>

FYI: FreeBSD's BPF implementation have JIT compilers in kernel on both
i386 and amd64.

-- 
Regards,
Changli Gao(xiaosuo@gmail.com)
