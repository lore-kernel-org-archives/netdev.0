From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next v3 1/5] netdev: introduce new
 NETIF_F_HW_NETFUNC_OFFLOAD feature flag for switch device offloads
Date: Fri, 23 Jan 2015 17:56:54 +0000
Message-ID: <20150123175654.GB25374@casper.infradead.org>
References: <1421987606-10884-2-git-send-email-roopa@cumulusnetworks.com>
 <20150123094459.GA2065@nanopsycho.orion>
 <54C26D4C.9050407@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jiri@resnulli.us>, sfeldma@gmail.com, jhs@mojatatu.com,
	bcrl@kvack.org, john.fastabend@gmail.com,
	stephen@networkplumber.org, vyasevic@redhat.com,
	ronen.arad@intel.com, netdev@vger.kernel.org, davem@davemloft.net,
	shm@cumulusnetworks.com, gospo@cumulusnetworks.com
To: roopa <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:48299 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754098AbbAWR46 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2015 12:56:58 -0500
Content-Disposition: inline
In-Reply-To: <54C26D4C.9050407@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/23/15 at 07:48am, roopa wrote:
> On 1/23/15, 1:44 AM, Jiri Pirko wrote:
> >How about rather "HW_DATAPATH_OFFLOAD"? Feels more accurate. By the
> >name, I still cannot understand what NETFUNC should mean.
> 
> It was supposed to mean 'network function offload'. sure, will consider
> HW_DATAPATH_OFFLOAD
> or if anybody has other suggestions.

I'm still fascinated that the description says 'for all switch asic
offloads', 'switch drivers', 'switch ports' but we try very hard to
come up with a different name ;-)
