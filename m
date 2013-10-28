From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/5] bonding: patchset for rcu use in
 bonding
Date: Mon, 28 Oct 2013 00:00:40 -0400 (EDT)
Message-ID: <20131028.000040.2194739018169129233.davem@davemloft.net>
References: <20131027211048.GA557@redhat.com>
	<20131027.174458.627996500790326920.davem@davemloft.net>
	<20131027221027.GA11209@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dingtianhong@huawei.com, fubar@us.ibm.com, andy@greyhouse.net,
	nikolay@redhat.com, netdev@vger.kernel.org
To: vfalico@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56082 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750920Ab3J1EAw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Oct 2013 00:00:52 -0400
In-Reply-To: <20131027221027.GA11209@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Veaceslav Falico <vfalico@redhat.com>
Date: Sun, 27 Oct 2013 23:10:27 +0100

> On Sun, Oct 27, 2013 at 05:44:58PM -0400, David Miller wrote:
>>I would have preferred that he did all of this in the initial 0/N
>>patch posting, but I can't defer forever.
> 
> Maybe I'm too picky. Anyway - understood, thanks.

I'm happy to revert his changes if you find real problems with them,
but I'd rather you two work more closely together in the future so I
don't have to break the deadlock like I did this time.

Thanks.
