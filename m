From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Should we report bus width/speed via ethtool?
Date: Wed, 05 Dec 2012 16:08:14 -0800
Message-ID: <50BFE1EE.6080902@hp.com>
References: <50BFBE05.7020408@candelatech.com> <20121205.173650.1310171220758794440.davem@davemloft.net> <50BFD417.7070306@candelatech.com> <20121205.190121.1400827550469329286.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:5410 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751980Ab2LFAIT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2012 19:08:19 -0500
In-Reply-To: <20121205.190121.1400827550469329286.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/05/2012 04:01 PM, David Miller wrote:
> lspci might be a good place to figure this out :-)  It's probably
> grovelling around in PCI config space to determine these things.

And if not lspci, "pcitop" used to grub around for such things, though 
its source may be rather moldy.  I'm sure though that if various chipset 
providers were willing to document their PCI performance counters, 
*someone* would be happy to bring pcitop into the present day...

happy benchmarking,

rick jones
