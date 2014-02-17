From: Yang Yingliang <yangyingliang@huawei.com>
Subject: Re: [PATCH net-next v2 3/3] sch_netem: replace magic numbers with
 enumerate in GE model
Date: Mon, 17 Feb 2014 14:38:38 +0800
Message-ID: <5301AE6E.5050504@huawei.com>
References: <1392345043-12208-1-git-send-email-yangyingliang@huawei.com>	 <1392345043-12208-4-git-send-email-yangyingliang@huawei.com> <1392554670.15615.93.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<stephen@networkplumber.org>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:35894 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750896AbaBQGjn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 01:39:43 -0500
In-Reply-To: <1392554670.15615.93.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/2/16 20:44, Ben Hutchings wrote:
> On Fri, 2014-02-14 at 10:30 +0800, Yang Yingliang wrote:
>> Replace some magic numbers which describe states of GE model
>> loss generator with enumerate.
> [...]
> 
> The name GOOD_STATE should also be used in get_loss_clg() where
> clgstate::state is initialised.
> 
> Ben.
> 
OK, thanks!

Regards,
Yang
