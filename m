From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH v2 2/2] netfilter: ip6t_SYNPROXY: fix sending window
 update to client
Date: Mon, 10 Aug 2015 13:58:58 +0200
Message-ID: <20150810115858.GB3260@salvia>
References: <20150808155746.GC29362@acer.localdomain>
 <1439118856-26484-1-git-send-email-phil@nwl.cc>
 <1439118856-26484-2-git-send-email-phil@nwl.cc>
 <20150810080607.GC20899@acer.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Phil Sutter <phil@nwl.cc>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150810080607.GC20899@acer.localdomain>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 10, 2015 at 10:06:07AM +0200, Patrick McHardy wrote:
> On 09.08, Phil Sutter wrote:
> > This is the identical fix as "netfilter: ipt_SYNPROXY: fix sending
> > window update to client" but for the IPv6 variant which obviously
> > suffers from the same issue.
> 
> Looks fine to me.
> 
> Acked-by: Patrick McHardy <kaber@trash.net>

Also applied, thanks.

> (Also for the IPv4 version, which for some reason I didn't receive)

I have collapsed the IPv4 chunk into this patch, the subject patch
name is:

netfilter: SYNPROXY: fix sending window update to client
