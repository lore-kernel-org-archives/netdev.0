From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 11/14] i40e: reorder block declarations in debugfs
Date: Fri, 18 Oct 2013 13:38:10 -0400 (EDT)
Message-ID: <20131018.133810.644337234048520007.davem@davemloft.net>
References: <1382102598-11343-12-git-send-email-jeffrey.t.kirsher@intel.com>
	<52614206.7050404@cogentembedded.com>
	<1382106892.2034.7.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sergei.shtylyov@cogentembedded.com, a@vger.kernel.org,
	shannon.nelson@intel.com, netdev@vger.kernel.org, gospo@redhat.com,
	sassmann@redhat.com, jesse.brandeburg@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56946 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756834Ab3JRRiM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Oct 2013 13:38:12 -0400
In-Reply-To: <1382106892.2034.7.camel@jtkirshe-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 18 Oct 2013 07:34:52 -0700

> On Fri, 2013-10-18 at 18:13 +0400, Sergei Shtylyov wrote:
>> On 18-10-2013 17:23, Jeff Kirsher wrote:
>> 
>> > From: Shannon Nelson <shannon.nelson@intel.com>
>> 
>> > This is a cleanup of the arguments declared at the beginning
>> > of each function.
>> 
>>     I hope you meant "local variables" because "arguments" are the
>> values 
>> passed to a function.
> 
> Yes, he meant local variables.

There is probably going to be some other feedback to address, so please
fix this commit message when you respin this series.

Thanks Jeff.
