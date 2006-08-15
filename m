From: Brice Goglin <brice@myri.com>
Subject: Re: [PATCH 0/3] myri10ge update
Date: Mon, 14 Aug 2006 20:25:29 -0400
Message-ID: <44E11479.7050106@myri.com>
References: <44E0F0A1.2000104@myri.com> <44E0F341.1090907@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from h-66-166-126-70.lsanca54.covad.net ([66.166.126.70]:44790 "EHLO
	myri.com") by vger.kernel.org with ESMTP id S932751AbWHOAZo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2006 20:25:44 -0400
To: Jeff Garzik <jeff@garzik.org>
In-Reply-To: <44E0F341.1090907@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> Brice Goglin wrote:
>> Hi,
>>
>> Here's 3 new minor updates for the myri10ge driver:
>>
>> 1) define some previously hardwired firmware constants
>> 2) allow to disable link status change reporting
>> 3) convert to netdev_alloc_skb
>
> Patches 1 and 3 look OK.  They are cleanups, and will need to go into
> #upstream (2.6.19) rather than #upstream-fixes (2.6.18-rc).
>
> Should I go ahead and attempt to apply 1 and 3, or wait?

Feel free to apply 1 and 3 on #upstream for 2.6.19 now. I will rework 2
and send it back later.

Thanks,
Brice

