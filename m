From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH v2 0/6] net sched: Fix broken late binding of
 actions
Date: Mon, 09 May 2016 00:30:48 -0400 (EDT)
Message-ID: <20160509.003048.2157155806457543450.davem@davemloft.net>
References: <1462728392-28489-1-git-send-email-jhs@emojatatu.com>
	<572F7761.2020103@mojatatu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54217 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750864AbcEIEav (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2016 00:30:51 -0400
In-Reply-To: <572F7761.2020103@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>
Date: Sun, 8 May 2016 13:29:05 -0400

> On 16-05-08 01:26 PM, Jamal Hadi Salim wrote:
>> From: Jamal Hadi Salim <jhs@mojatatu.com>
>>
>> Some actions were broken in allowing for late binding of actions.
> 
> Dave, these deserve to go into -stable as well.

Then don't target them at 'net-next'.  If it's good enough for -stable
it's by definition good enough for 'net'.
