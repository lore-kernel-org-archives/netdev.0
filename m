From: Bruce Allen <ballen@gravity.phys.uwm.edu>
Subject: Re: e1000 full-duplex TCP performance well below wire speed
Date: Thu, 31 Jan 2008 13:37:32 -0600 (CST)
Message-ID: <Pine.LNX.4.63.0801311328030.14403@trinity.phys.uwm.edu>
References: <Pine.LNX.4.63.0801300324000.6391@trinity.phys.uwm.edu>
 <20080130.055333.192844925.davem@davemloft.net>
 <Pine.LNX.4.63.0801300758020.11487@trinity.phys.uwm.edu>
 <20080130082136.1017631d@deepthought> <Pine.LNX.4.63.0801301610240.19938@trinity.phys.uwm.edu>
 <649aecc70801301617m6331bcb8i8ce60366e182c739@mail.gmail.com>
 <20080131064533.ef0ae932.billfink@mindspring.com>
 <Pine.LNX.4.63.0801310951060.10967@trinity.phys.uwm.edu>
 <20080131123627.599be68f.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: SANGTAE HA <sangtae.ha@gmail.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: Bill Fink <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from trinity.phys.uwm.edu ([129.89.57.159]:37305 "EHLO
	trinity.phys.uwm.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760038AbYAaThi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2008 14:37:38 -0500
In-Reply-To: <20080131123627.599be68f.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Bill,

>>> I see similar results on my test systems
>>
>> Thanks for this report and for confirming our observations.  Could you
>> please confirm that a single-port bidrectional UDP link runs at wire
>> speed?  This helps to localize the problem to the TCP stack or interaction
>> of the TCP stack with the e1000 driver and hardware.
>
> Yes, a single-port bidirectional UDP test gets full GigE line rate
> in both directions with no packet loss.

Thanks for confirming this.  And thanks also for nuttcp!  I just 
recognized you as the author.

Cheers,
 	Bruce
