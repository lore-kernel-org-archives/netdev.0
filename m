From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sctp: fix compile issue with disabled
 CONFIG_NET_NS
Date: Thu, 16 Aug 2012 13:36:57 -0700 (PDT)
Message-ID: <20120816.133657.56561695743634072.davem@davemloft.net>
References: <20120816112449.GA17354@uweber-WS>
	<87fw7m64v9.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ulrich.weber@sophos.com, netdev@vger.kernel.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35102 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755555Ab2HPUg6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Aug 2012 16:36:58 -0400
In-Reply-To: <87fw7m64v9.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Thu, 16 Aug 2012 11:58:34 -0700

> Ulrich Weber <ulrich.weber@sophos.com> writes:
> 
>> struct seq_net_private has no struct net
>> if CONFIG_NET_NS is not enabled
> 
> My mistake.
> 
> Reviewed-by: "Eric W. Biederman" <ebiederm@xmission.com>
> 
>> Signed-off-by: Ulrich Weber <ulrich.weber@sophos.com>

Applied.
