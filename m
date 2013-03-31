From: Balakumaran Kannan <kumaran.4353@gmail.com>
Subject: Re: [PATCH v2] net IPv6 : Fix broken IPv6 routing table after
 loopback down-up
Date: Sun, 31 Mar 2013 12:08:04 +0530
Message-ID: <CAHPKR9+=fFPTpjdE+diyXDvjEdPcqcRXJvWP_rHWrqB7wMTEPA@mail.gmail.com>
References: <CAHPKR9L4Y0=cbH7w_iZ20CBsH=nt4UuZwyBvDOMSrMmM_sJt1w@mail.gmail.com>
	<CAHPKR9J4vmPp6SFn-betmb6GLimZE6dRf0Tapeu5jzyUJ=vK6Q@mail.gmail.com>
	<CAHPKR9J=niSHrGmeX7ZM-1fosjnRA_CFrfd+ha3zwNibNGe1bg@mail.gmail.com>
	<20130329.151759.1699178800809051958.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: eric.dumazet@gmail.com, yoshfuji@linux-ipv6.org, kaber@trash.net,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	Balakumaran.Kannan@ap.sony.com, maruthi.thotad@ap.sony.com,
	netdev@vger.kernel.org, jamshed.a@ap.sony.com,
	amit.agarwal@ap.sony.com, takuzo.ohara@jp.sony.com,
	aaditya.kumar@ap.sony.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f172.google.com ([74.125.82.172]:54593 "EHLO
	mail-we0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752187Ab3CaGiG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Mar 2013 02:38:06 -0400
Received: by mail-we0-f172.google.com with SMTP id r3so1155218wey.17
        for <netdev@vger.kernel.org>; Sat, 30 Mar 2013 23:38:04 -0700 (PDT)
In-Reply-To: <20130329.151759.1699178800809051958.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>  static void addrconf_add_linklocal(struct inet6_dev *idev, const
>> struct in6_addr *addr)
>
> Your email client corrupted this patch, please resubmit but only after
> you have emailed the patch to yourself and successfully applied the
> patch you receive in that test email.
>
> Thanks.

I'll send working patch after verifying it.

Thank you.
K.Balakumaran
