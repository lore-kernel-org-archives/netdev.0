From: Florian Weimer <fweimer@redhat.com>
Subject: Re: [PATCH 00/19] netfilter: IPv6 NAT
Date: Mon, 27 Aug 2012 09:33:39 +0200
Message-ID: <503B22D3.4020109@redhat.com>
References: <1344542943-11588-1-git-send-email-kaber@trash.net> <5038233F.7000202@tomt.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: Andre Tomt <andre@tomt.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <5038233F.7000202@tomt.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/25/2012 02:58 AM, Andre Tomt wrote:
> On 09. aug. 2012 22:08, kaber@trash.net wrote:
>> The following patches contain an updated version of IPv6 NAT against
>> Linus' current tree.
>
> Hmmm. Looking in my crystal ball (hi #ipv6!), I predict that if this
> lands in mainline - and thus in consumer CPE/routers eventually - many
> ISP's will have little incentive to actually implement assigning of
> blocks to their consumer users like they "have to" today.

I think the brokenness of IPv6 ND is still sufficient incentive to 
provide the customer with a prefix.  Whether this prefix is constant 
over an extended period of time is a separate question.  Even among 
consumers, preferences vary widely.

-- 
Florian Weimer / Red Hat Product Security Team
