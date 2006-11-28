From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH-2.4] e100: incorrect use of "&&" instead of "&"
Date: Tue, 28 Nov 2006 00:03:05 -0800
Message-ID: <456BED39.8090402@intel.com>
References: <20061125213517.GA5965@1wt.eu> <456B20F6.8010009@intel.com>
 <20061128010538.GA22370@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Auke Kok <auke-jan.h.kok@intel.com>,
	NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vms048pub.verizon.net ([206.46.252.48]:17111 "EHLO
	vms048pub.verizon.net") by vger.kernel.org with ESMTP
	id S935686AbWK1HGe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Nov 2006 02:06:34 -0500
Received: from ahkok-mobl.jf.intel.com ([72.87.43.215])
 by vms048.mailsrvcs.net (Sun Java System Messaging Server 6.2-6.01 (built Apr
 3 2006)) with ESMTPA id <0J9F000D5IDU7L6O@vms048.mailsrvcs.net> for
 netdev@vger.kernel.org; Tue, 28 Nov 2006 01:05:55 -0600 (CST)
In-reply-to: <20061128010538.GA22370@1wt.eu>
To: Willy Tarreau <w@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Willy Tarreau wrote:
> Hi Auke,
> 
> On Mon, Nov 27, 2006 at 09:31:34AM -0800, Auke Kok wrote:
>> Willy Tarreau wrote:
>>> Hi guys,
>>>
>>> I'm about to apply this fix to 2.4. 2.6 is not affected.
>>> Do you have any objection ?
>> Willy,
>>
>> you didn't CC netdev. linux-net is a users list, you didn't CC the 
>> maintainers of the driver. Please do this. We're more than happy to help, 
>> even for 2.4 kernels.
> 
> I'm really sorry, as I usually use netdev and not linux-net. I don't know
> why I used this one in the first step. There might have been some fog
> inside my head.
> 
> BTW, there's no clear maintainer identified for e100. At best I can find
> "linux.nics@intel.com" in the file, without any freshness info. Is that
> still OK or do you want to update the MAINTAINERS file ?

I'll post a patch for it, it's definately out of date :(

Auke

