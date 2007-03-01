From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH] e1000 stop raw interrupts disabled nag from RT
Date: Thu, 01 Mar 2007 09:29:22 -0800
Message-ID: <45E70D72.5020803@intel.com>
References: <45E64080.4070004@mvista.com> <45E645F4.2090403@intel.com> <45E65DCF.8050903@mvista.com> <45E70586.60201@intel.com> <45E70959.4070209@stud.feec.vutbr.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>,
	Mark Huth <mhuth@mvista.com>, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Ingo Molnar <mingo@elte.hu>
To: Michal Schmidt <xschmi00@stud.feec.vutbr.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:46876 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965459AbXCAR3u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Mar 2007 12:29:50 -0500
In-Reply-To: <45E70959.4070209@stud.feec.vutbr.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michal Schmidt wrote:
> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA1
> 
> Kok, Auke wrote:
>> Mark Huth wrote:
>>> Well, I'm not an expert on the realtime patches - but most any patch set 
>>> from Ingo seems to set this off - we've run through a bunch all the way 
>>> since 2.6.10.
>> that's bizarre, and would imply that Ingo himself never spotted this in ages, 
>> not to mention never tell us about it?
> 
> Ingo's -rt patches have contained this change to e1000 for some time.
> The code is perfectly fine as is for non-RT kernels, so maybe that's why
> noone felt like telling you about it.

uhh, sure... while we are at it then, are there any more patches like this? 
perhaps for e100? ixgb?

Cheers,

Auke


