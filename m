From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [RFC PATCH v2] iproute2: bridge: add veb/vepa toggle
Date: Tue, 06 Nov 2012 08:42:19 -0800
Message-ID: <50993DEB.9080508@intel.com>
References: <20121103032436.8744.12352.stgit@localhost6.localdomain6> <20121105095039.3156a216@s6510.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:30080 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751060Ab2KFQmU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Nov 2012 11:42:20 -0500
In-Reply-To: <20121105095039.3156a216@s6510.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/5/2012 12:50 AM, Stephen Hemminger wrote:
> On Fri, 02 Nov 2012 20:24:36 -0700
> John Fastabend <john.r.fastabend@intel.com> wrote:
>
>> Test bridge commands to set veb, vepa modes to iproute2.

[...]

>> +};
>> +#define IFLA_BRIDGE_MAX (__IFLA_BRIDGE_MAX - 1)
>> +
>>   enum {
>>   	PORT_REQUEST_PREASSOCIATE = 0,
>>   	PORT_REQUEST_PREASSOCIATE_RR,
>>
>
> This looks ok. I will roll it into the resubmit of bridge changes
> when I get back from Linuxcon.
>

Sounds good thanks. I'll test what you come up with when I see
it.
