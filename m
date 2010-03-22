From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [RFC] GTSM for IPv6
Date: Mon, 22 Mar 2010 16:14:59 +0900
Message-ID: <4BA718F3.7050103@linux-ipv6.org>
References: <20100319095640.42c8d82d@nehalam> <alpine.LRH.2.00.1003191959050.31512@netcore.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Pekka Savola <pekkas@netcore.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:57064 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753483Ab0CVHPU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Mar 2010 03:15:20 -0400
In-Reply-To: <alpine.LRH.2.00.1003191959050.31512@netcore.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(2010/03/20 3:02), Pekka Savola wrote:
> On Fri, 19 Mar 2010, Stephen Hemminger wrote:
>> Also RFC doesn't explicitly address GTSM on IPV6.
>> Maybe the RFC editors think the problem will magically no longer exist
>> in IPv6 world because everyone will be using IPsec.
>
> Hmm. When I was editing the RFC, I seem to have put in some text about
> IPv6 (i.e. difference in TTL vs Hop Count naming). As far as I know,
> there is no other difference :-)
>
> In IPV6_MIN_HOPS hops would seem to point toward the "number of hops"
> which is logically the opposite: 255-$value. So maybe IPV6_MIN_HOPCOUNT
> is better. But I can live with it either way :-)
>

Or, how about IPV6_MAX_HOPS, then? :-)

--yoshfuji
