From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] [UDPv6] Possible dst leak in udpv6_sendmsg.
Date: Wed, 04 Jun 2008 01:36:21 +0900 (JST)
Message-ID: <20080604.013621.52164911.yoshfuji@linux-ipv6.org>
References: <1212493845.6499.29.camel@iris.sw.ru>
	<20080604.012619.30196060.yoshfuji@linux-ipv6.org>
	<1212510848.12028.0.camel@iris.sw.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, kaber@trash.net,
	yoshfuji@linux-ipv6.org
To: den@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:58023 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751995AbYFCQfo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 12:35:44 -0400
In-Reply-To: <1212510848.12028.0.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <1212510848.12028.0.camel@iris.sw.ru> (at Tue, 03 Jun 2008 20:34:08 +0400), "Denis V. Lunev" <den@openvz.org> says:

> Acked-by: Denis V. Lunev <den@openvz.org>

Okay, I'm queueing this for net-2.6.  Thanks.

--yoshfuji
