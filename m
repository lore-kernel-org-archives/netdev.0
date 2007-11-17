From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/5] udp: memory limitation by using udp_mem
Date: Fri, 16 Nov 2007 20:01:12 -0800 (PST)
Message-ID: <20071116.200112.249418928.davem@davemloft.net>
References: <20071115.152353.100893781.davem@davemloft.net>
	<20071116021241.GD32509@gondor.apana.org.au>
	<473E5760.3020802@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	satoshi.oshima.fk@hitachi.com, billfink@mindspring.com,
	andi@firstfloor.org, johnpol@2ka.mipt.ru,
	shemminger@linux-foundation.org, yoshfuji@linux-ipv6.org,
	yumiko.sugita.yf@hitachi.com
To: haoki@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37549
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755719AbXKQEBO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Nov 2007 23:01:14 -0500
In-Reply-To: <473E5760.3020802@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hideo AOKI <haoki@redhat.com>
Date: Fri, 16 Nov 2007 21:52:16 -0500

> I understood that memory accounting code should avoid special
> protocols checks.  Then, I'll improve this part in next patch set.

Thank you for continuing this work, it is very much appreciated.
