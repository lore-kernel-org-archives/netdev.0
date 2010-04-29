From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: speedup udp receive path
Date: Fri, 30 Apr 2010 07:07:09 +0800
Message-ID: <u2u412e6f7f1004291607j4b7b9c3ct4fb78de7bffc7fc0@mail.gmail.com>
References: <1272010378-2955-1-git-send-email-xiaosuo@gmail.com>
	<1272454432.14068.4.camel@bigi> <1272458001.2267.0.camel@edumazet-laptop>
	<1272458174.14068.16.camel@bigi> <1272463605.2267.70.camel@edumazet-laptop>
	<1272498293.4258.121.camel@bigi> <1272514176.2201.85.camel@edumazet-laptop>
	<1272540952.4258.161.camel@bigi> <u2l412e6f7f1004290512x7fcdb5c3w591c6446d676502@mail.gmail.com>
	<1272545108.2222.65.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hadi@cyberus.ca, David Miller <davem@davemloft.net>,
	therbert@google.com, shemminger@vyatta.com, netdev@vger.kernel.org,
	Eilon Greenstein <eilong@broadcom.com>,
	Brian Bloniarz <bmb@athenacr.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:35708 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933889Ab0D3SNZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Apr 2010 14:13:25 -0400
Received: by mail-pv0-f174.google.com with SMTP id 7so299691pvg.19
        for <netdev@vger.kernel.org>; Fri, 30 Apr 2010 11:13:20 -0700 (PDT)
In-Reply-To: <1272545108.2222.65.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 29, 2010 at 8:45 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
>
> Changli, I wonder how you can cook "performance" patches without test=
ing
> them at all for real... This cannot be true ?
>

I am sorry. But I wasn't against your patch, and I just wanted to
understand the test result from jamal. It is my fault submitting a
performance patch without testing them. I should not reply on code
inspection for the performance patch.

--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
