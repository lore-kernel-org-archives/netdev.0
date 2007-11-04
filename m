From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: Endianness problem with u32 classifier hash masks
Date: Sun, 04 Nov 2007 02:17:54 +0100
Message-ID: <472D1DC2.9000106@o2.pl>
References: <1193939701.2987.82.camel@localhost.localdomain>	 <472B5EF1.4020206@o2.pl> <1194045830.4438.21.camel@localhost> <472D06B2.9040402@o2.pl> <472D0B1C.7000209@o2.pl> <472D128B.8030704@o2.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, Radu Rendec <radu.rendec@ines.ro>,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx12.go2.pl ([193.17.41.142]:51096 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755813AbXKDBMn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 3 Nov 2007 21:12:43 -0400
In-Reply-To: <472D128B.8030704@o2.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jarek Poplawski wrote, On 11/04/2007 01:30 AM:

> Jarek Poplawski wrote, On 11/04/2007 12:58 AM:
... 
> Other changes seem to be not needed.
> 
>> But it needs more checking...


But not much more: it's a piece of fshit!

So, even if not full ntohl(), some byte moving seems to be
necessary here.

Sorry for this mess, 
Jarek P
