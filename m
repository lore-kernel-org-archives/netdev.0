From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] rename RTNH_F_EXTERNAL to RTNH_F_OFFLOAD
Date: Thu, 21 May 2015 23:19:35 -0400 (EDT)
Message-ID: <20150521.231935.790321925069995084.davem@davemloft.net>
References: <20150521151618.5fb0d6a7@urahara>
	<20150521.184010.1674602649748676614.davem@davemloft.net>
	<20150521164630.23fbba18@urahara>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: roopa@cumulusnetworks.com, sfeldma@gmail.com, jiri@resnulli.us,
	gospo@cumulusnetworks.com, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42270 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753854AbbEVDTj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2015 23:19:39 -0400
In-Reply-To: <20150521164630.23fbba18@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Thu, 21 May 2015 16:46:30 -0700

> On Thu, 21 May 2015 18:40:10 -0400 (EDT)
> David Miller <davem@davemloft.net> wrote:
> 
>> From: Stephen Hemminger <stephen@networkplumber.org>
>> Date: Thu, 21 May 2015 15:16:18 -0700
>> 
>> > On Thu, 14 May 2015 22:45:54 -0400 (EDT)
>> > David Miller <davem@davemloft.net> wrote:
>> > 
>> >> From: roopa@cumulusnetworks.com
>> >> Date: Wed, 13 May 2015 21:17:41 -0700
>> >> 
>> >> > From: Roopa Prabhu <roopa@cumulusnetworks.com>
>> >> > 
>> >> > RTNH_F_EXTERNAL today is printed as "offload" in iproute2 output.
>> >> > 
>> >> > This patch renames the flag to be consistent with what the user sees.
>> >> > 
>> >> > Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
>> >> 
>> >> Applied, thanks.
>> > 
>> > I don't see this merge in current net-next tree?
>> > Did it not really happen or was it not pushed?
>> 
>> It went to the 'net' tree and I haven't done a merge in a while.
> 
> Ok, that will go to Linus, right.
> Trying to coordinate the iproute2 changes related to this.

Yes, probably I will send him a pull request tomorrow.
