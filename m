From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] net_sched: avoid generating same handle for u32
 filters
Date: Sun, 20 Jul 2014 20:49:41 -0700 (PDT)
Message-ID: <20140720.204941.2049170221961813123.davem@davemloft.net>
References: <53CAEC2F.4050808@mojatatu.com>
	<CAM_iQpU8P=sgbtOfjZ8QD6maoMCfwoiTgEsiEVG7M=j3M3v22g@mail.gmail.com>
	<53CBEC4D.5000103@mojatatu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, netdev@vger.kernel.org,
	cwang@twopensource.com
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52894 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752074AbaGUDtm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jul 2014 23:49:42 -0400
In-Reply-To: <53CBEC4D.5000103@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>
Date: Sun, 20 Jul 2014 12:20:29 -0400

> On 07/19/14 18:15, Cong Wang wrote:
>> On Sat, Jul 19, 2014 at 3:07 PM, Jamal Hadi Salim <jhs@mojatatu.com>
>> wrote:
> 
>>
>> gen_new_kid() is called only when handle is not specified by user.
>>
> 
> Ok, thanks. Please add my sign-off.

Jamal, please in the future just simply say:

Signed-off-by: Jamal ...

when you want your signoff to get added, it's more work for everyone
otherwise.

Thanks.
