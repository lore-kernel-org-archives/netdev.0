From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [IPv6] addrconf: Check range of prefix length
Date: Thu, 29 May 2008 00:47:44 +0900 (JST)
Message-ID: <20080529.004744.89720114.yoshfuji@linux-ipv6.org>
References: <20080528145422.GE20815@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:53530 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751387AbYE1PrP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 May 2008 11:47:15 -0400
In-Reply-To: <20080528145422.GE20815@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <20080528145422.GE20815@postel.suug.ch> (at Wed, 28 May 2008 16:54:22 +0200), Thomas Graf <tgraf@suug.ch> says:

> Due to the missing check, the currently code allows for any 8 bit
> value to be passed on as prefix length while using the netlink
> interface, and any 32 bit value while using the ioctl interface.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

I'm going to apply think.  Thank you.

--yoshfuji
