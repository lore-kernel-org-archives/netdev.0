From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] Mobile IPv6 introduction
Date: Tue, 01 Aug 2006 18:04:59 -0700 (PDT)
Message-ID: <20060801.180459.93386858.davem@davemloft.net>
References: <20060729141244.GJ8334@innerghost.net>
	<20060801.173535.38709014.davem@davemloft.net>
	<20060802005849.GK8334@innerghost.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nakam@linux-ipv6.org, yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi,
	vnuorval@tcs.hut.fi, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:28360
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750922AbWHBBEy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Aug 2006 21:04:54 -0400
To: hsantos@av.it.pt
In-Reply-To: <20060802005849.GK8334@innerghost.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hugo Santos <hsantos@av.it.pt>
Date: Wed, 2 Aug 2006 01:58:49 +0100

>    Still regarding Subtrees, is there any interest in revitalizing that
>  code? I have a couple patches that i could submit.

I'm not sure.  If we implement a routing cache front end
for the ipv6 FIB, which is very likely, the backend data
structures aren't so important any longer.
