From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] ipv6: use ipv6_addr_any() helper
Date: Thu, 23 May 2013 01:18:11 -0700 (PDT)
Message-ID: <20130523.011811.341395150492183016.davem@davemloft.net>
References: <1369237266-21742-1-git-send-email-xiyou.wangcong@gmail.com>
	<519CED0E.9050708@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: xiyou.wangcong@gmail.com, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52745 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751386Ab3EWISP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 May 2013 04:18:15 -0400
In-Reply-To: <519CED0E.9050708@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Wed, 22 May 2013 18:06:38 +0200

> Le 22/05/2013 17:41, Cong Wang a =E9crit :
>> From: Cong Wang <xiyou.wangcong@gmail.com>
>>
>> ipv6_addr_any() is a faster way to determine if an addr
>> is ipv6 any addr, no need to compute the addr type.
>>
>> Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>> Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
>> Cc: David S. Miller <davem@davemloft.net>
>> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
>>
> Acked-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied.
