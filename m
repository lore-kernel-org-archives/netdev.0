From: "Marco Berizzi" <pupilla@hotmail.com>
Subject: Re: ipsec tunnel asymmetrical mtu
Date: Fri, 09 Jun 2006 10:04:42 +0200
Message-ID: <BAY103-F1811A7081DDF94CCCC2158B2880@phx.gbl>
References: <BAY103-F5BDFFFFDAB4CFB03007D9B2A60@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bay103-f18.bay103.hotmail.com ([65.54.174.28]:7498 "EHLO
	hotmail.com") by vger.kernel.org with ESMTP id S1751428AbWFIIEn
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jun 2006 04:04:43 -0400
In-Reply-To: <BAY103-F5BDFFFFDAB4CFB03007D9B2A60@phx.gbl>
To: herbert@gondor.apana.org.au
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Marco Berizzi wrote:

>Marco Berizzi wrote:
>
>>Herbert Xu wrote:
>>
>>>However, the fact that the tcpdump causes more chunky packets to
>>>make it through could be an indication that there is a bug somewhere
>>>in our NAT/IPsec code or at least a suboptimal memory allocation
>>>strategy that's somehow avoided when AF_PACKET pins the skb down.
>
>JFYI: same problem with 2.6.17-rc4-git5

JFYI: same problem with 2.6.17-rc6


