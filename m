From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vlan: cleanup the usage of *vlan in
 vlan_dev_hard_header
Date: Thu, 01 Aug 2013 17:12:16 -0700 (PDT)
Message-ID: <20130801.171216.1136894769601545257.davem@davemloft.net>
References: <51F9FBCF.9060405@gmail.com>
	<20130801.131230.25199405118866430.davem@davemloft.net>
	<51FAF636.1090802@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: shhuiw@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56091 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757371Ab3HBAMT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Aug 2013 20:12:19 -0400
In-Reply-To: <51FAF636.1090802@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Sheng-Hui <shhuiw@gmail.com>
Date: Fri, 02 Aug 2013 07:58:46 +0800

> On 2013年08月02日 04:12, David Miller wrote:
>> From: Wang Sheng-Hui <shhuiw@gmail.com>
>> Date: Thu, 01 Aug 2013 14:10:23 +0800
>>
>>> We can use vlan directly after we get the pointer at the beginning
>>>      *vlan = vlan_dev_priv(dev)
>>> and do not use vlan_dev_priv(dev) to access its fields afterwards.
>>>
>>> Signed-off-by: Wang Sheng-Hui <shhuiw@gmail.com>
>>
>> This patch was corrupted by your email client.
>>
> 
> Sorry. Please recheck the patch below.

Please make a fresh patch posting, don't use a reply to this thread.

Thank you.
