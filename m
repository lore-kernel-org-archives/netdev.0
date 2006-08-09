From: Patrick Caulfield <patrick@tykepenguin.com>
Subject: Re: Rules and groups
Date: Wed, 09 Aug 2006 17:20:00 +0100
Message-ID: <44DA0B30.7070100@tykepenguin.com>
References: <20060809080139.GA19555@souterrain.chygwyn.com> <20060809.010125.78708459.davem@davemloft.net> <20060809100326.GA23935@souterrain.chygwyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, tgraf@suug.ch,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from spc1-leed3-0-0-cust958.seac.broadband.ntl.com ([82.8.19.191]:45560
	"EHLO fentible.pjc.net") by vger.kernel.org with ESMTP
	id S1751279AbWHIReG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Aug 2006 13:34:06 -0400
To: Steven Whitehouse <steve@chygwyn.com>
In-Reply-To: <20060809100326.GA23935@souterrain.chygwyn.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Steven Whitehouse wrote:
> Hi,
> 
> On Wed, Aug 09, 2006 at 01:01:25AM -0700, David Miller wrote:
>> From: Steven Whitehouse <steve@chygwyn.com>
>> Date: Wed, 9 Aug 2006 09:01:39 +0100
>>
>>> Is there anything to stop me using RTNLGRP_NOP3 for that? (suitable
>>> renamed of course!) So far as I can see its never been assigned to
>>> anything else...
>> I have no objection to you using it.
>>
> Excellent. Please find attached my attempt at doing the conversion to the
> generic rules code. It appears to work ok for me. You can also pull this
> patch from the decnet git tree at:
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/steve/decnet-2.6.19.git
> 
> which was cloned from net-2.6.19.git quite recently. In addition the
> git tree has another patch which is in a following email.
> 
> Patrick: does this patch get your blessing?
> 


Yes, that works fine for me.


-- 
patrick
