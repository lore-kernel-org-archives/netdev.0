From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v3 1/5] netdev: introduce new
 NETIF_F_HW_NETFUNC_OFFLOAD feature flag for switch device offloads
Date: Fri, 23 Jan 2015 20:05:18 +0100
Message-ID: <20150123190518.GP2065@nanopsycho.orion>
References: <1421987606-10884-2-git-send-email-roopa@cumulusnetworks.com>
 <20150123094459.GA2065@nanopsycho.orion>
 <54C26D4C.9050407@cumulusnetworks.com>
 <20150123175654.GB25374@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: roopa <roopa@cumulusnetworks.com>, sfeldma@gmail.com,
	jhs@mojatatu.com, bcrl@kvack.org, john.fastabend@gmail.com,
	stephen@networkplumber.org, vyasevic@redhat.com,
	ronen.arad@intel.com, netdev@vger.kernel.org, davem@davemloft.net,
	shm@cumulusnetworks.com, gospo@cumulusnetworks.com
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f176.google.com ([74.125.82.176]:65421 "EHLO
	mail-we0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752848AbbAWTFY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2015 14:05:24 -0500
Received: by mail-we0-f176.google.com with SMTP id w62so9279918wes.7
        for <netdev@vger.kernel.org>; Fri, 23 Jan 2015 11:05:23 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20150123175654.GB25374@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Jan 23, 2015 at 06:56:54PM CET, tgraf@suug.ch wrote:
>On 01/23/15 at 07:48am, roopa wrote:
>> On 1/23/15, 1:44 AM, Jiri Pirko wrote:
>> >How about rather "HW_DATAPATH_OFFLOAD"? Feels more accurate. By the
>> >name, I still cannot understand what NETFUNC should mean.
>> 
>> It was supposed to mean 'network function offload'. sure, will consider
>> HW_DATAPATH_OFFLOAD
>> or if anybody has other suggestions.
>
>I'm still fascinated that the description says 'for all switch asic
>offloads', 'switch drivers', 'switch ports' but we try very hard to
>come up with a different name ;-)

+1
But we'll see in future. I bet that "switch" will stick.
