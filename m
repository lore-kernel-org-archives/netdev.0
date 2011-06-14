From: Fernando Luis =?ISO-8859-1?Q?V=E1zquez?= Cao
	<fernando@oss.ntt.co.jp>
Subject: Re: [PATCH 0/2] IGMP snooping: set mrouters_only flag properly
Date: Tue, 14 Jun 2011 10:01:41 +0900
Message-ID: <1308013301.3896.6.camel@nexus.oss.ntt.co.jp>
References: <1307933995.2704.11.camel@nausicaa>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from serv2.oss.ntt.co.jp ([222.151.198.100]:54686 "EHLO
	serv2.oss.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752497Ab1FNBBm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2011 21:01:42 -0400
In-Reply-To: <1307933995.2704.11.camel@nausicaa>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-06-13 at 11:59 +0900, Fernando Luis Vazquez Cao wrote:
> I am sending you a fix for a IGMP snooping bug that bit us when we tried
> to deploy it in production. This bug has been present since day one in
> the IGMP code and I think the fix deserves a backport to -stable
> (>=2.6.34).
> 
> The reason I am sending you separate patches for IPv4 and IPv6 is that I
> wanted to acknowledge Hayato Kakuta for his extensive testing of IPv4's
> IGMP code.

I fat fingered the subject of the first patch and found some typos. I
will be replying to this email with the updated patches. I am sorry for
the noise.

David, would you be picking up these fixes or should they go through
someone else's tree. Hopefully I got the mailing list right this time
around.

Thanks,
Fernando

