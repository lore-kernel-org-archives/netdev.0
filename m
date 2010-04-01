From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH net-next-2.6] ipv6 fib: Make ip6_fib{} more cache-line
 aware.
Date: Thu, 01 Apr 2010 17:26:24 +0900
Message-ID: <4BB458B0.40609@linux-ipv6.org>
References: <201004010818.o318IZ6f025510@94.43.138.210.xn.2iij.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:58288 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754232Ab0DAI07 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Apr 2010 04:26:59 -0400
In-Reply-To: <201004010818.o318IZ6f025510@94.43.138.210.xn.2iij.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(2010/04/01 17:18), YOSHIFUJI Hideaki wrote:
:
> Let's rearrange ip6_fib{}.

Oops, I should say rt6_info{}.  Resent.

--yoshfuji
