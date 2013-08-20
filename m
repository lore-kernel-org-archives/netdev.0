From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] r8169,sis190: remove unnecessary length check
Date: Tue, 20 Aug 2013 14:58:15 -0700 (PDT)
Message-ID: <20130820.145815.2199502754774931416.davem@davemloft.net>
References: <1376694473-8517-1-git-send-email-lekensteyn@gmail.com>
	<20130820204558.GA26241@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lekensteyn@gmail.com, bhutchings@solarflare.com,
	netdev@vger.kernel.org
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47783 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751266Ab3HTV6p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Aug 2013 17:58:45 -0400
In-Reply-To: <20130820204558.GA26241@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Tue, 20 Aug 2013 22:45:58 +0200

> Peter Wu <lekensteyn@gmail.com> :
> [...]
>> This was observed by Ben[1] while reviewing my other r8169 register dump
>> patch. I have combined the r8169 and sis190 patches since they were
>> trivial and both maintained by Francois. Let me know if you prefer to
>> split this trivial patch up.
> 
> (missed this one)
> 
> I'm fine with it.

Applied to net-next, thanks everyone.
