From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH 0/8] e100, e1000: Fixes for netdev-2.6#upstream-fixes
Date: Mon, 23 Oct 2006 08:13:04 -0700
Message-ID: <453CDC00.2020705@intel.com>
References: <20061017190139.4194.20128.stgit@gitlost.site> <453A6769.4000305@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:9829 "EHLO mga02.intel.com")
	by vger.kernel.org with ESMTP id S964922AbWJWPPU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2006 11:15:20 -0400
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <453A6769.4000305@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> Kok, Auke wrote:
>> Hi,
>>
>> The following fixes targeted to netdev-2.6#upstream-fixes are available
>> through git:
>>
>> git pull git://lost.foo-projects.org/~ahkok/git/netdev-2.6 upstream-fixes
> 
> hrm.  since another e100 fixes got applied, can you either (a) update 
> the above URL for that change, or (b) provide separate e100 and e1000 
> pull urls?

I dropped the e100 patch from the series, it now contains (at the above url) only the 
e1000 changes.

Cheers,

Auke
