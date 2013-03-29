From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net IPv6 : Fix broken IPv6 routing table after
 loopback down-up
Date: Fri, 29 Mar 2013 15:17:59 -0400 (EDT)
Message-ID: <20130329.151759.1699178800809051958.davem@davemloft.net>
References: <CAHPKR9L4Y0=cbH7w_iZ20CBsH=nt4UuZwyBvDOMSrMmM_sJt1w@mail.gmail.com>
	<CAHPKR9J4vmPp6SFn-betmb6GLimZE6dRf0Tapeu5jzyUJ=vK6Q@mail.gmail.com>
	<CAHPKR9J=niSHrGmeX7ZM-1fosjnRA_CFrfd+ha3zwNibNGe1bg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, yoshfuji@linux-ipv6.org, kaber@trash.net,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	Balakumaran.Kannan@ap.sony.com, maruthi.thotad@ap.sony.com,
	netdev@vger.kernel.org, jamshed.a@ap.sony.com,
	amit.agarwal@ap.sony.com, takuzo.ohara@jp.sony.com,
	aaditya.kumar@ap.sony.com
To: kumaran.4353@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56202 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756395Ab3C2TSB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Mar 2013 15:18:01 -0400
In-Reply-To: <CAHPKR9J=niSHrGmeX7ZM-1fosjnRA_CFrfd+ha3zwNibNGe1bg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Balakumaran Kannan <kumaran.4353@gmail.com>
Date: Thu, 28 Mar 2013 20:44:36 +0530

>  static void addrconf_add_linklocal(struct inet6_dev *idev, const
> struct in6_addr *addr)

Your email client corrupted this patch, please resubmit but only after
you have emailed the patch to yourself and successfully applied the
patch you receive in that test email.

Thanks.
