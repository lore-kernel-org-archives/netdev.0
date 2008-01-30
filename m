From: Bruce Allen <ballen@gravity.phys.uwm.edu>
Subject: Re: e1000 full-duplex TCP performance well below wire speed
Date: Wed, 30 Jan 2008 17:15:41 -0600 (CST)
Message-ID: <Pine.LNX.4.63.0801301707450.19938@trinity.phys.uwm.edu>
References: <Pine.LNX.4.63.0801300621290.6391@trinity.phys.uwm.edu>
 <36D9DB17C6DE9E40B059440DB8D95F52044F81DF@orsmsx418.amr.corp.intel.com>
 <47A0C5B2.1000500@hp.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org,
	Carsten Aulbert <carsten.aulbert@aei.mpg.de>,
	Henning Fehrmann <henning.fehrmann@aei.mpg.de>,
	Bruce Allen <bruce.allen@aei.mpg.de>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from trinity.phys.uwm.edu ([129.89.57.159]:42362 "EHLO
	trinity.phys.uwm.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753639AbYA3XQ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2008 18:16:26 -0500
In-Reply-To: <47A0C5B2.1000500@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Rick,

First off, thanks for netperf. I've used it a lot and find it an extremely 
useful tool.

>> As asked in LKML thread, please post the exact netperf command used to
>> start the client/server, whether or not you're using irqbalanced (aka
>> irqbalance) and what cat /proc/interrupts looks like (you ARE using MSI,
>> right?)
>
> In particular, it would be good to know if you are doing two concurrent 
> streams, or if you are using the "burst mode" TCP_RR with large 
> request/response sizes method which then is only using one connection.

I'm not sure -- must wait for Henning and Carsten to respond tomorrow.

Cheers,
 	Bruce
