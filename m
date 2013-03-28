From: Balakumaran Kannan <kumaran.4353@gmail.com>
Subject: Re: [PATCH v2] net IPv6 : Fix broken IPv6 routing table after
 loopback down-up
Date: Thu, 28 Mar 2013 19:34:51 +0530
Message-ID: <CAHPKR9L4Y0=cbH7w_iZ20CBsH=nt4UuZwyBvDOMSrMmM_sJt1w@mail.gmail.com>
References: <CAHPKR9KE4LT_AEzUZ8cuJwBeMEEu0Ppe+jjynFQk7+N-A4YUmQ@mail.gmail.com>
	<1364478265.15753.42.camel@edumazet-glaptop>
	<1364478316.15753.43.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yoshfuji@linux-ipv6.org, davem@davemloft.net,
	Patrick McHardy <kaber@trash.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, jmorris@namei.org,
	Balakumaran.Kannan@ap.sony.com, maruthi.thotad@ap.sony.com,
	netdev@vger.kernel.org, jamshed.a@ap.sony.com,
	amit.agarwal@ap.sony.com, takuzo.ohara@jp.sony.com,
	aaditya.kumar@ap.sony.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:37360 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754922Ab3C1OEw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Mar 2013 10:04:52 -0400
Received: by mail-wi0-f182.google.com with SMTP id hi18so3264591wib.15
        for <netdev@vger.kernel.org>; Thu, 28 Mar 2013 07:04:51 -0700 (PDT)
In-Reply-To: <1364478316.15753.43.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 28, 2013 at 7:15 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2013-03-28 at 06:44 -0700, Eric Dumazet wrote:
>
>> __in6_dev_get() should be OK.
>
> more exactly : __in_dev_get_rtnl()
>
>
>

Thank you for your comments. I'll update the patch and send it.
