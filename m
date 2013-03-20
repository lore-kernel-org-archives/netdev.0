From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] genetlink: trigger BUG_ON if a group name is too
 long
Date: Wed, 20 Mar 2013 17:05:11 -0400 (EDT)
Message-ID: <20130320.170511.343122156621608721.davem@davemloft.net>
References: <1363693648-10015-2-git-send-email-yamato@redhat.com>
	<20130320.120705.58997943737455552.davem@davemloft.net>
	<CAE9FiQURBR=iTbksUzb_i23g6N56Acg2J8bab9zr1UcwT5tWzA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rui.zhang@intel.com, yamato@redhat.com, netdev@vger.kernel.org
To: yinghai@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34108 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751197Ab3CTVFQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Mar 2013 17:05:16 -0400
In-Reply-To: <CAE9FiQURBR=iTbksUzb_i23g6N56Acg2J8bab9zr1UcwT5tWzA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yinghai Lu <yinghai@kernel.org>
Date: Wed, 20 Mar 2013 14:01:09 -0700

> On Wed, Mar 20, 2013 at 9:07 AM, David Miller <davem@davemloft.net> wrote:
>> From: Masatake YAMATO <yamato@redhat.com>
>> Date: Tue, 19 Mar 2013 20:47:27 +0900
>>
>>> Trigger BUG_ON if a group name is longer than GENL_NAMSIZ.
>>>
>>> Signed-off-by: Masatake YAMATO <yamato@redhat.com>
>>
>> Applied, thanks.
> 
> catch one in

Seriously?

That's what his second patch in this series fixes, we know about it
already.
