From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: add sysfs entry for device group
Date: Mon, 24 Jan 2011 23:23:38 -0800 (PST)
Message-ID: <20110124.232338.39194948.davem@davemloft.net>
References: <1295876249-15634-1-git-send-email-ddvlad@rosedu.org>
	<20110125144106.1cbd12b0@s6510>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ddvlad@rosedu.org, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41729
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751599Ab1AYHXE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jan 2011 02:23:04 -0500
In-Reply-To: <20110125144106.1cbd12b0@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 25 Jan 2011 14:41:06 +1000

> On Mon, 24 Jan 2011 15:37:29 +0200
> Vlad Dogaru <ddvlad@rosedu.org> wrote:
> 
>> The group of a network device can be queried or changed from userspace
>> using sysfs.
>> 
>> For example, considering sysfs mounted in /sys, one can change the group
>> that interface lo belongs to:
>> 	echo 1 > /sys/class/net/lo/group
>> 
>> Signed-off-by: Vlad Dogaru <ddvlad@rosedu.org>
> 
> Acked-by: Stephen Hemminger <shemminger@vyatta.com>

Applied to net-next-2.6, thanks.
