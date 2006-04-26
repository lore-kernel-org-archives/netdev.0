From: "Marco Berizzi" <pupilla@hotmail.com>
Subject: Re: ipsec tunnel asymmetrical mtu
Date: Wed, 26 Apr 2006 14:20:01 +0200
Message-ID: <BAY103-F4D24B7F9D9E55A3688643B2BC0@phx.gbl>
References: <20060426105546.GA11726@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bay103-f4.bay103.hotmail.com ([65.54.174.14]:47228 "EHLO
	hotmail.com") by vger.kernel.org with ESMTP id S932413AbWDZMUG
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Apr 2006 08:20:06 -0400
In-Reply-To: <20060426105546.GA11726@gondor.apana.org.au>
To: herbert@gondor.apana.org.au
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:

>On Mon, Apr 24, 2006 at 09:23:00AM +0000, Marco Berizzi wrote:
> >
> > What should I do? Mangling MSS with iptables  --set-mss ?
> > Altering MSS to 1440 did the trick. See:
> > http://marc.theaimsgroup.com/?l=linux-netdev&m=114373067423528&w=2
>
>--clamp-mss-to-pmtu should be the best option.

Ok. thanks for the tip.
Have you discovered anything about the bug?
Do you need other info?


