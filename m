From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: [PATCH] ICMP: ICMP_MIB_OUTMSGS increment duplicated
Date: Thu, 17 Jan 2008 08:55:50 +0800
Message-ID: <478EA796.9080001@cn.fujitsu.com>
References: <OF0A9FA609.40104566-ON882573D2.0057C6DA-882573D2.005A0894@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, davem@davemloft.net,
	netdev@vger.kernel.org
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:64076 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750917AbYAQA5K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jan 2008 19:57:10 -0500
In-Reply-To: <OF0A9FA609.40104566-ON882573D2.0057C6DA-882573D2.005A0894@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Stevens said the following on 2008-1-17 0:23:
> Wang,
>         I think your patch is correct; did you test the same case for 
> IPv6?
> 

I've tested IPv4, but IPv6 not yet.
If Davem accept this one, I will see the IPv6, or you take care of it.

--
WCN

