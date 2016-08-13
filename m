From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] sit: make function ipip6_valid_ip_proto() static
Date: Fri, 12 Aug 2016 21:52:42 -0700 (PDT)
Message-ID: <20160812.215242.1919409824941088414.davem@davemloft.net>
References: <1471053255-31395-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57211 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750866AbcHMEyN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Aug 2016 00:54:13 -0400
In-Reply-To: <1471053255-31395-1-git-send-email-weiyj.lk@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Sat, 13 Aug 2016 01:54:15 +0000

> Fixes the following sparse warning:
> 
> net/ipv6/sit.c:1129:6: warning:
>  symbol 'ipip6_valid_ip_proto' was not declared. Should it be static?
> 
> Signed-off-by: Wei Yongjun <weiyj.lk@gmail.com>

Applied.
