From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [RFC] Multiple IPV6 Routing Tables & Policy Routing
Date: Sat, 29 Jul 2006 13:27:07 +0900 (JST)
Message-ID: <20060729.132707.43201856.yoshfuji@linux-ipv6.org>
References: <20060726221100.325687073@postel.suug.ch>
	<20060728.151009.54809236.yoshfuji@linux-ipv6.org>
	<20060728103229.GD14627@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vnuorval@tcs.hut.fi,
	usagi-core@linux-ipv6.org, davem@davemloft.net, anttit@tcs.hut.fi,
	yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:20999 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S1161449AbWG2EZl
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Jul 2006 00:25:41 -0400
To: tgraf@suug.ch
In-Reply-To: <20060728103229.GD14627@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <20060728103229.GD14627@postel.suug.ch> (at Fri, 28 Jul 2006 12:32:29 +0200), Thomas Graf <tgraf@suug.ch> says:

> * YOSHIFUJI Hideaki / ?$B5HF#1QL@ <yoshfuji@linux-ipv6.org> 2006-07-28 15:10
> > Well, as you stated, the code is based on the work of MIPL,
> > which is being jointly developed by Helsinki University of Technology (HUT)
> > and USAGI/WIDE Project.  Please describe this on your commit logs.
> > Please retain copyright information as well.
> 
> Please tell me which copyright I missed? 

Please put these lines in net/ipv6/fib6_rules.c
(and maybe, its derived files):

  Copyright (C)2003-2006 Helsinki University of Technology
  Copyright (C)2003-2006 USAGI/WIDE Project

You can add your own copyright notice if you want, of course.

Thank you.

--yoshfuji
