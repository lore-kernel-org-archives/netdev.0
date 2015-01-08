From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: REGRESSION in nfnetlink on 3.18.x (bisected)
Date: Thu, 8 Jan 2015 11:47:14 +0100
Message-ID: <20150108104714.GA3463@salvia>
References: <5496075F.3060204@tomt.net>
 <20141222115607.GA4961@salvia>
 <5498A7DF.6040903@tomt.net>
 <54ADAD1E.3060101@tomt.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Andre Tomt <andre@tomt.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <54ADAD1E.3060101@tomt.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 07, 2015 at 11:03:10PM +0100, Andre Tomt wrote:
> On 23. des. 2014 00:23, Andre Tomt wrote:
> >On 22. des. 2014 12:56, Pablo Neira Ayuso wrote:
> >>Could you give a test to this patch? Thanks.
> >>
> >
> >Initial testing looks good with this patch applied on top of 3.18.1
> >I will give it a spin on some more systems tomorrow.
> 
> No news is good news :-)
> 
> ~10 3.18.x systems in various roles have had this fix for two weeks
> with no issues.

Thanks a lot for testing. I already sent the patch to David:

http://patchwork.ozlabs.org/patch/426205/
