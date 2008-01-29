From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [RFC/PATCH] e100 driver didn't support any MII-less PHYs...
Date: Tue, 29 Jan 2008 15:09:25 -0800
Message-ID: <479FB225.7090604@intel.com>
References: <20071228235118.GA31059@rhlx01.hs-esslingen.de> <477732A5.5020501@intel.com> <20080101200908.GA14805@rhlx01.hs-esslingen.de> <20080129230315.GA13389@rhlx01.hs-esslingen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, bunk@kernel.org
To: andi@lisas.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:26449 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752156AbYA2XK3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jan 2008 18:10:29 -0500
In-Reply-To: <20080129230315.GA13389@rhlx01.hs-esslingen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andreas Mohr wrote:
> Hi,
> 
> On Tue, Jan 01, 2008 at 09:09:08PM +0100, Andreas Mohr wrote:
>> Thanks for your quick reply!
>>
>> OK, here's part 1, the MII-less support stuff.
>> (preliminary posting, for review only)
>>
>> Note that these diffs apply to 2.6.24-rc6-mm1 without much trouble,
>> thus might want to do -mm testing soon.
> 
> Any verdict on this one?
> 
> I happen to be asking now since silly me just ""upgraded"" a mere mortal's
> sorta-production machine to 2.6.24 proper without remembering
> that the previous -rc6 had contained a minor but effective change
> to make those wires do their thing. Or, to tell it as it was,
> "Mom wasn't impressed ;)".
> 
> Perhaps it's useful to file a bug/patch
> on http://sourceforge.net/projects/e1000/ ? Perhaps -mm testing?

I wanted to push this though our testing labs first which has not happened due to
time constraints - that should quickly at least confirm that the most common nics
work OK after the change with your patch. I'll try and see if we can get this
testing done soon.

Auke


