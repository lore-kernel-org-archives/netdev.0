From: Hideo AOKI <haoki@redhat.com>
Subject: Re: [PATCH 4/4] [UDP]: memory accounting in IPv4
Date: Thu, 20 Dec 2007 22:58:38 -0500
Message-ID: <476B39EE.1020909@redhat.com>
References: <47673195.80004@redhat.com>	<476732B7.9040502@redhat.com> <20071220.034437.126882771.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	tyasui@redhat.com, mhiramat@redhat.com,
	satoshi.oshima.fk@hitachi.com, billfink@mindspring.com,
	andi@firstfloor.org, johnpol@2ka.mipt.ru,
	shemminger@linux-foundation.org, yoshfuji@linux-ipv6.org,
	yumiko.sugita.yf@hitachi.com, haoki@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:43114 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753976AbXLUEAo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Dec 2007 23:00:44 -0500
In-Reply-To: <20071220.034437.126882771.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Hideo AOKI <haoki@redhat.com>
> Date: Mon, 17 Dec 2007 21:38:47 -0500
> 
>> This patch adds UDP memory usage accounting in IPv4.
>>
> We can't accept these changes, even once the other issues
> are fixed, until IPV6 is supported as well.
> 
> It's pointless to support proper UDP memory accounting only
> in IPV4 and not in IPV6 as well.

I understood. I'll develop IPv6 UDP memory accounting as well and
include it in next UDP memory accounting patch set submission.

Many thanks,
Hideo

-- 
Hitachi Computer Products (America) Inc.
