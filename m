From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH][IPv4/IPv6] Setting 0 for unused port field. (fwd)
Date: Wed, 26 Jul 2006 09:02:00 +0900 (JST)
Message-ID: <20060726.090200.69427685.yoshfuji@linux-ipv6.org>
References: <Pine.LNX.4.64.0607251045470.21222@d.namei>
	<20060725.235340.99246287.yoshfuji@linux-ipv6.org>
	<20060725.165436.127672564.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jmorris@namei.org, netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:18707 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S1030275AbWGZAAi
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Jul 2006 20:00:38 -0400
To: davem@davemloft.net
In-Reply-To: <20060725.165436.127672564.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <20060725.165436.127672564.davem@davemloft.net> (at Tue, 25 Jul 2006 16:54:36 -0700 (PDT)), David Miller <davem@davemloft.net> says:

> > Well, instead, should it be initalized to protocol number, shouldn't it?
> 
> Initially, this was my reaction too.  But, aparently it is defined
> to be zero, from TCP/IP Illustrated Volume 2, page 1055, which is
:

Okay, Acked.

Acked-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

--yoshfuji
