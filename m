From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [net-next-2.6 PATCH v2 0/3] Series short description
Date: Sun, 02 Jan 2011 18:27:08 -0800
Message-ID: <4D2133FC.3050902@intel.com>
References: <20101230192449.21487.9764.stgit@jf-dev1-dcblab> <20101231.104941.189703153.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Liu, Lucy" <lucy.liu@intel.com>,
	"shmulikr@broadcom.com" <shmulikr@broadcom.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:32744 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753261Ab1ACC1J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 2 Jan 2011 21:27:09 -0500
In-Reply-To: <20101231.104941.189703153.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/31/2010 10:49 AM, David Miller wrote:
> From: John Fastabend <john.r.fastabend@intel.com>
> Date: Thu, 30 Dec 2010 11:25:40 -0800
> 
>> Version 2 adds the recommended tlv attributes to the ets struct this will
>> be needed for offloaded LLDP engines. Host controlled LLDP agents will most
>> likely not use these fields.
>>
>> Also Shmulik Ravid caught an error with a spin_lock on kmalloc failure.
> 
> BTW, even though I replied "applied" to v1 of these patches I made
> sure to actully apply v2 :-)
> --

Thanks David.
