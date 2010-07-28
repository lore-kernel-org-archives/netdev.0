From: David Miller <davem@davemloft.net>
Subject: Re: [patch -next] ixgbe: potential null dereference
Date: Tue, 27 Jul 2010 20:48:50 -0700 (PDT)
Message-ID: <20100727.204850.186297061.davem@davemloft.net>
References: <20100727100556.GM26313@bicker>
	<AANLkTim5LGj0KGs-0fGGAka7Fde3=NVVXWYBLbb_kVMs@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: error27@gmail.com, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, alexander.h.duyck@intel.com,
	peter.p.waskiewicz.jr@intel.com, john.ronciak@intel.com,
	donald.c.skidmore@intel.com, mallikarjuna.chilakala@intel.com,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34333
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753330Ab0G1Dsd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jul 2010 23:48:33 -0400
In-Reply-To: <AANLkTim5LGj0KGs-0fGGAka7Fde3=NVVXWYBLbb_kVMs@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 27 Jul 2010 17:10:02 -0700

> On Tue, Jul 27, 2010 at 03:05, Dan Carpenter <error27@gmail.com> wrote:
>> The e_dev_err() macro dereferences "adapter" which is NULL here.
>>
>> Signed-off-by: Dan Carpenter <error27@gmail.com>
> 
> Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
