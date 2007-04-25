From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [2/2] [IPV6]: Consolidate common SNMP code
Date: Wed, 25 Apr 2007 13:21:03 +0900 (JST)
Message-ID: <20070425.132103.129791594.yoshfuji@linux-ipv6.org>
References: <20070425040409.GA4807@gondor.apana.org.au>
	<20070425040637.GA4838@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: herbert@gondor.apana.org.au, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:32980 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161605AbXDYEVF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2007 00:21:05 -0400
In-Reply-To: <20070425040637.GA4838@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <20070425040637.GA4838@gondor.apana.org.au> (at Wed, 25 Apr 2007 14:06:37 +1000), Herbert Xu <herbert@gondor.apana.org.au> says:

> Hi:
> 
> [IPV6]: Consolidate common SNMP code
> 
> This patch moves the non-proc SNMP code into addrconf.c and reuses
> IPv4 SNMP code where applicable.
:
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>


Acked-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

--yoshfuji
