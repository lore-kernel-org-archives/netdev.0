From: Pavel Simerda <psimerda@redhat.com>
Subject: Re: [patch net-next V2] bond: have random dev address by default
 instead of zeroes
Date: Fri, 25 Jan 2013 12:56:27 -0500 (EST)
Message-ID: <542237717.4200599.1359136587903.JavaMail.root@redhat.com>
References: <21365.1359136387@death.nxdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, andy@greyhouse.net,
	stephen@networkplumber.org, dcbw@redhat.com,
	Jiri Pirko <jiri@resnulli.us>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4-phx2.redhat.com ([209.132.183.25]:41263 "EHLO
	mx4-phx2.redhat.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755243Ab3AYR4f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jan 2013 12:56:35 -0500
In-Reply-To: <21365.1359136387@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

----- Original Message -----
> From: "Jay Vosburgh" <fubar@us.ibm.com>
> but I don't think it should be changed.

Just a short question. Is there any reason for bonding interfaces to behave differently from bridging interfaces in this respect?

Cheers,

Pavel
