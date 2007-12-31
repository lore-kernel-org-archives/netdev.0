From: Hideo AOKI <haoki@redhat.com>
Subject: Re: [PATCH 2/4] [CORE]: adding memory accounting points
Date: Mon, 31 Dec 2007 13:52:40 -0500
Message-ID: <47793A78.3050100@redhat.com>
References: <47775B25.7020401@redhat.com>	<47775C20.5010004@redhat.com> <20071230.235806.171376126.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, vladislav.yasevich@hp.com,
	netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net,
	tyasui@redhat.com, mhiramat@redhat.com,
	satoshi.oshima.fk@hitachi.com, billfink@mindspring.com,
	andi@firstfloor.org, johnpol@2ka.mipt.ru,
	shemminger@linux-foundation.org, yoshfuji@linux-ipv6.org,
	yumiko.sugita.yf@hitachi.com, haoki@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:52852 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750935AbXLaSxj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Dec 2007 13:53:39 -0500
In-Reply-To: <20071230.235806.171376126.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:

> This patch would not apply, because is contained changes
> present in the first patch, specifically:
<snip>
> And now I see exactly what you did, and it is quite careless.
> 
> You wrote one big patch then tried to split it up by hand.  This
> proves to me that you did not test the patches individually.  Even
> worse, you did not even try to apply each patch nor compile the tree
> each step along the way as a basic sanity check.

Hello David,

You are right. Since I felt the patch was big, I divided
into three for review. And I mistook during the dividing.

> This wastes a lot of my time, as well as the time of other developers
> who might want to try out and test your changes.

I apologize for wasting your time.


> I will fix it up this time, but please do not ever do this again.

I really appreciate the fix. And I understood this.

Best regards,
Hideo

-- 
Hitachi Computer Products (America) Inc.
