From: "Marco Berizzi" <pupilla@hotmail.com>
Subject: Re: ipsec tunnel asymmetrical mtu
Date: Thu, 18 May 2006 10:46:56 +0200
Message-ID: <BAY103-F5BDFFFFDAB4CFB03007D9B2A60@phx.gbl>
References: <BAY103-F1D9D892CDA10889FCB525B2A80@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bay103-f5.bay103.hotmail.com ([65.54.174.15]:55578 "EHLO
	hotmail.com") by vger.kernel.org with ESMTP id S1750781AbWERIrA
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 May 2006 04:47:00 -0400
In-Reply-To: <BAY103-F1D9D892CDA10889FCB525B2A80@phx.gbl>
To: herbert@gondor.apana.org.au
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Marco Berizzi wrote:

>Herbert Xu wrote:
>
>>However, the fact that the tcpdump causes more chunky packets to
>>make it through could be an indication that there is a bug somewhere
>>in our NAT/IPsec code or at least a suboptimal memory allocation
>>strategy that's somehow avoided when AF_PACKET pins the skb down.

JFYI: same problem with 2.6.17-rc4-git5


