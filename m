From: David Miller <davem@davemloft.net>
Subject: Re: [patch net/stable] ipv6/exthdrs: accept tlv which includes
 only padding
Date: Sat, 07 Sep 2013 21:50:20 -0400 (EDT)
Message-ID: <20130907.215020.38125291010941900.davem@davemloft.net>
References: <1378476145-6282-1-git-send-email-jiri@resnulli.us>
	<alpine.LNX.2.00.1309071427120.1262@heraclitus>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net
To: eldad@fogrefinery.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42000 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751151Ab3IHBuW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Sep 2013 21:50:22 -0400
In-Reply-To: <alpine.LNX.2.00.1309071427120.1262@heraclitus>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eldad Zack <eldad@fogrefinery.com>
Date: Sat, 7 Sep 2013 14:31:36 +0200 (CEST)

> On Fri, 6 Sep 2013, Jiri Pirko wrote:
> 
>> Current behaviour breaks TAHI Test v6LC.1.2.6.
> 
> I'm not familiar with this, but IMHO the test should be reversed :)

I think I agree with Eldad on this, and that TAHI should be adjusted
to have more reasonable expectations of an implementation.
