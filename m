From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH 2/2] act_mirred: optimization
Date: Mon, 16 Nov 2009 21:22:46 +0800
Message-ID: <412e6f7f0911160522w34895b0eked14f69ccc62c96b@mail.gmail.com>
References: <20091116.024839.257258321.davem@davemloft.net>
	 <20091116.025859.78494103.davem@davemloft.net>
	 <412e6f7f0911160505x10da9a92j694669db9d030da1@mail.gmail.com>
	 <20091116.051722.255835290.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hadi@cyberus.ca, shemminger@vyatta.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f42.google.com ([209.85.160.42]:47128 "EHLO
	mail-pw0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752809AbZKPNWk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2009 08:22:40 -0500
Received: by pwi3 with SMTP id 3so3255443pwi.21
        for <netdev@vger.kernel.org>; Mon, 16 Nov 2009 05:22:46 -0800 (PST)
In-Reply-To: <20091116.051722.255835290.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 16, 2009 at 9:17 PM, David Miller <davem@davemloft.net> wro=
te:
> From: Changli Gao <xiaosuo@gmail.com>
> Date: Mon, 16 Nov 2009 21:05:28 +0800
>
>> I am sorry about that. But I did test it before submitting these two=
,
>> and I am just wondering if they are applied without any error. Would
>> you post the file after being patched? I think it will be helpful to
>> finger out the real problem.
>
> I don't have time for that sorry.

Thanks all the same!

>
> I think the problem might be that you are developing against
> either net-2.6 or Linus's tree, whereas you should be working
> against net-next-2.6
>

I am working against linux-next. I'll check if there is any
difference. BTW: were these patches applied in order, 1 - 2?

--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
