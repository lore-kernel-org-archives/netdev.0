From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] ipsec: fix IPv4 AH alignment on 32 bits
Date: Fri, 28 Jan 2011 11:46:10 -0800 (PST)
Message-ID: <20110128.114610.193716130.davem@davemloft.net>
References: <20110128045108.GA8351@gondor.apana.org.au>
	<4D42839C.3050401@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	christophe.gouault@6wind.com
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38244
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751220Ab1A1Tpf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jan 2011 14:45:35 -0500
In-Reply-To: <4D42839C.3050401@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Fri, 28 Jan 2011 09:51:40 +0100

> On 28/01/2011 05:51, Herbert Xu wrote:
>> So perhaps an SA configuration flag is needed?
> I agree. If David is ok, I will update the patch.

Sounds good to me.
