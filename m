From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] smsc95xx: mark link down on startup and let PHY
 interrupt deal with carrier changes
Date: Thu, 26 Apr 2012 05:56:35 -0400 (EDT)
Message-ID: <20120426.055635.352589797599676545.davem@davemloft.net>
References: <20120424.004240.51699724664176823.davem@davemloft.net>
	<CAKh2mn4JLm8f036d7vNimLdA2wCP+Db7xhgUgfsg760yhs3Yjw@mail.gmail.com>
	<CAKh2mn6YM=Jmpmfr7ErM0cRjsMc97DzoBLcA45gh9yzSpQDRJg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fillods@users.sf.net, paolo.pisati@canonical.com,
	netdev@vger.kernel.org
To: steve@shawell.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58522 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750908Ab2DZJ4u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2012 05:56:50 -0400
In-Reply-To: <CAKh2mn6YM=Jmpmfr7ErM0cRjsMc97DzoBLcA45gh9yzSpQDRJg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Glendinning <steve@shawell.net>
Date: Thu, 26 Apr 2012 10:41:33 +0100

> Hi all,
> 
> On 24 April 2012 16:45, Steve Glendinning <steve@shawell.net> wrote:
>> Hi all,
>>
>> On 24 April 2012 05:42, David Miller <davem@davemloft.net> wrote:
>>>
>>> Steve, please send a maintainers etc. update and please provide
>>> feedback on this link status fix.
> 
> Good catch Paolo, this patch fixes reporting of link status when the
> device is first connected with no ethernet cable plugged in.
> 
> I'll prepare the same patch for smsc75xx as it also suffers from the same issue.
> 
> Acked-by: Steve Glendinning <steve.glendinning@shawell.net>

Applied.
