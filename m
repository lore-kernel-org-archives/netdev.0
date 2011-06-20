From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [PATCH 0/7] Series short description
Date: Mon, 20 Jun 2011 09:05:38 -0700
Message-ID: <4DFF6FD2.2020909@intel.com>
References: <20110617211027.26578.11317.stgit@jf-dev1-dcblab> <1308506310.15528.6.camel@lb-tlvb-shmulik.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Shmulik Ravid <shmulikr@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:54272 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753838Ab1FTQHe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Jun 2011 12:07:34 -0400
In-Reply-To: <1308506310.15528.6.camel@lb-tlvb-shmulik.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/19/2011 10:58 AM, Shmulik Ravid wrote:
> 
> On Fri, 2011-06-17 at 14:16 -0700, John Fastabend wrote:
>> The following series implements improvements to the DCB netlink
>> interface. This work was done to improve Application handling
>> and support firmware based LLDP agents.
>>
>> This adds a multicast group for DCB currently user space has
>> trouble keeping in sync across multiple applications and with
>> firmware agents making DCB attribute changes in the driver.
>>
> 
> I was working on something along the same lines and would like to add on
> top of these changes a notification for the CEE flavor.
>  

Yes please do. This would be helpful I just haven't got to it
yet. Anyways we will need something like this to support CEE
based firmware implementations.

Thanks,
John
