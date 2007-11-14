From: Hideo AOKI <haoki@redhat.com>
Subject: Re: [PATCH 1/5] fix send buffer check
Date: Tue, 13 Nov 2007 22:25:00 -0500
Message-ID: <473A6A8C.6060906@redhat.com>
References: <47264E2D.4080109@redhat.com> <47264F2D.3010105@redhat.com> <20071109122416.GC27984@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Satoshi Oshima <satoshi.oshima.fk@hitachi.com>,
	Andi Kleen <andi@firstfloor.org>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	yoshfuji@linux-ipv6.org,
	Yumiko Sugita <yumiko.sugita.yf@hitachi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:43644 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756629AbXKND07 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Nov 2007 22:26:59 -0500
In-Reply-To: <20071109122416.GC27984@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

I'm sorry that my response is always late.

Herbert Xu wrote:
> On Mon, Oct 29, 2007 at 05:22:53PM -0400, Hideo AOKI wrote:
>> This patch introduces sndbuf size check before memory allocation for
>> send buffer.
> 
> Looks good, what about IPv6?

I'm going to develop IPv6 part if IPv4 patch set is accepted.

Many thanks,
Hideo

--
Hitachi Computer Products (America) Inc.
