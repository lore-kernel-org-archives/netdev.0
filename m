From: Rick Jones <rick.jones2@hp.com>
Subject: Re: e1000 full-duplex TCP performance well below wire speed
Date: Thu, 31 Jan 2008 11:07:31 -0800
Message-ID: <47A21C73.4070301@hp.com>
References: <Pine.LNX.4.63.0801300621290.6391@trinity.phys.uwm.edu>	<36D9DB17C6DE9E40B059440DB8D95F52044F81DF@orsmsx418.amr.corp.intel.com>	<Pine.LNX.4.63.0801301635470.19938@trinity.phys.uwm.edu>	<36D9DB17C6DE9E40B059440DB8D95F52044F8BA3@orsmsx418.amr.corp.intel.com>	<Pine.LNX.4.63.0801310213010.3240@trinity.phys.uwm.edu>	<47A20E9E.7070503@intel.com> <47A215A8.2090104@hp.com> <47A217CE.4000002@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Bruce Allen <ballen@gravity.phys.uwm.edu>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org,
	Carsten Aulbert <carsten.aulbert@aei.mpg.de>,
	Henning Fehrmann <henning.fehrmann@aei.mpg.de>,
	Bruce Allen <bruce.allen@aei.mpg.de>
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0026.austin.hp.com ([15.216.28.33]:42109 "EHLO
	g1t0026.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754100AbYAaTHd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2008 14:07:33 -0500
In-Reply-To: <47A217CE.4000002@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>Sounds like tools to show PCI* bus utilization would be helpful...
> 
> 
> that would be a hardware profiling thing and highly dependent on the part sticking
> out of the slot, vendor bus implementation etc... Perhaps Intel has some tools for
> this already but I personally do not know of any :/

Small matter of getting specs for the various LBA's (is that the correct 
term? - lower bus adaptors) and then abstracting them a la the CPU perf 
counters as done by say perfmon and then used by papi :)

rick jones
