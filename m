From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [ethtool PATCH 0/6] Network flow classifier
Date: Thu, 21 Apr 2011 14:11:20 -0700
Message-ID: <4DB09D78.4000708@intel.com>
References: <20110421202857.23054.63316.stgit@gitlad.jf.intel.com> <1303419093.3165.57.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:1086 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754021Ab1DUVLf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Apr 2011 17:11:35 -0400
In-Reply-To: <1303419093.3165.57.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/21/2011 1:51 PM, Ben Hutchings wrote:
> On Thu, 2011-04-21 at 13:40 -0700, Alexander Duyck wrote:
>> The following patches are meant to add support for the network flow classifier
>> interface built into the ethtool_rxnfc.
>>
>> Once this has been accepted I plan to submit the kernel portion to Jeff
>> Kirsher as it is almost all ixgbe code changes with the exception of the
>> removal of support for ethtool_get_rx_ntuple from the kernel.
> [...]
>
> This is the start of a 4-way weekend in the UK, so don't be surprised if
> I take a while to review these changes.
>
> Ben.
>

I'm fine with that.  I wasn't in any big hurry.  I was mostly just 
getting them out there for review so that I can probably see about 
polishing them up and submitting the final version for them next week.

Thanks,

Alex
