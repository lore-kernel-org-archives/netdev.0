From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: Re: New commands to configure IOV features
Date: Mon, 16 Jul 2012 12:19:23 +0300
Message-ID: <5003DC9B.8000706@broadcom.com>
References: <4FA7AF62.8000405@broadcom.com>
 <20120507081634.000003f8.gregory.v.rose@intel.com>
 <4FE9A963.7020602@broadcom.com> <20120626101903.0000791c@unknown>
 <1341859155.2535.43.camel@bwh-desktop.uk.solarflarecom.com>
 <4FFB4985.3040507@genband.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Chris Friesen" <chris.friesen@genband.com>,
	"Ben Hutchings" <bhutchings@solarflare.com>,
	"Greg Rose" <gregory.v.rose@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-pci@vger.kernel.org
To: "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4185 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750754Ab2GPJUD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jul 2012 05:20:03 -0400
In-Reply-To: <4FFB4985.3040507@genband.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


>>>> If I want to pick the RFCs and add support for configuring the number
>>>> of VFs - do you think ethtool's the right place for such added
>>>> support?
>>>>
>>> I think a PCI utility tool would be better, SR-IOV is not limited to
>>> network devices.  That's one of the reasons I dropped the RFC.  I
>>> haven't gotten back to the idea since then due to my day job keeping me
>>> pretty busy.
>>
>> For what it's worth, I agree with this.
> 
> From my perspective it would be ideal if this could be exported via /sys or something
> 


Well, obviously unless there was a sudden change in our stance regarding
sysfs we will not head that way.

This thread got no replies from the pci community, and I'm unfamiliar
with such a tool.

Dave, What's your stance in the matter - do you wish us to continue pursuing
some pci tool (which might or might not exist), or instead work on
a networking solution to this issue?

Do you happen to know such a tool?

Thanks,
Yuval
