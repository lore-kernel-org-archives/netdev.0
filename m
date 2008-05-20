From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC, VLAN]: Propagate selected feature bits to VLAN devices
Date: Tue, 20 May 2008 19:23:54 +0200
Message-ID: <4833092A.3070800@trash.net>
References: <4832E223.7020206@trash.net> <20080520144822.GR28241@solarflare.com> <4832E55E.2030009@trash.net> <4832F260.5000104@candelatech.com> <20080520162011.GT28241@solarflare.com> <4832FC1F.90208@candelatech.com> <D5C1322C3E673F459512FB59E0DDC329051AC81F@orsmsx414.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:45461 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754159AbYETRXy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 May 2008 13:23:54 -0400
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC329051AC81F@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Waskiewicz Jr, Peter P wrote:
>> I guess it doesn't matter so much to me either way..so long 
>> as it is narrowed one way or another, and preferably narrowed 
>> enough to allow plenty of new flags down the road.
> 
> In addition to TSO, we also want TCP checksum offload, so we'll need at
> least one more flag.  So whatever is done to shrink the GSO bits, we'll
> need room for two new flags.

You're right of course, seems I wasn't thinking :)

> 
> The patch looks good after a visual inspection.  I'll send test results
> later today.

Thanks.
