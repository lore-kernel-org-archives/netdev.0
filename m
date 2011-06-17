From: vkolluri <vkolluri@cisco.com>
Subject: Re: [next-next-2.6 PATCH] enic: Add support to configure hardware
 interrupt coalesce timers in a platform independent way
Date: Fri, 17 Jun 2011 10:27:50 -0700
Message-ID: <CA20DCA6.5F74%vkolluri@cisco.com>
References: <20110616.235715.2076846351080666905.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-3.cisco.com ([171.71.176.72]:37971 "EHLO
	sj-iport-3.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752307Ab1FQR1y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2011 13:27:54 -0400
In-Reply-To: <20110616.235715.2076846351080666905.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'll fix and resubmit.

Thanks
Vasanthy


On 6/16/11 8:57 PM, "David Miller" <davem@davemloft.net> wrote:

> From: Vasanthy Kolluri <vkolluri@cisco.com>
> Date: Wed, 15 Jun 2011 14:17:58 -0700
> 
>> + /* Get interrupt coalesce timer info
>> +  */
>> +
>> + err = enic_dev_intr_coal_timer_info(enic);
> 
> Please, comment should be just one line long and empty
> line is superflous.

