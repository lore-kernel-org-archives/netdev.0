From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next v2] ping: always initialize ->sin6_scope_id
 and ->sin6_flowinfo
Date: Tue, 04 Jun 2013 16:59:09 -0700 (PDT)
Message-ID: <20130604.165909.2293402783644406303.davem@davemloft.net>
References: <1370249032-14903-1-git-send-email-amwang@redhat.com>
	<CAKD1Yr1f=LtJGnzOEoy2Co2A_2LzqjSdU6dJZWCy3+WeXWJe3g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: amwang@redhat.com, netdev@vger.kernel.org
To: lorenzo@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60387 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752066Ab3FDX7K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jun 2013 19:59:10 -0400
In-Reply-To: <CAKD1Yr1f=LtJGnzOEoy2Co2A_2LzqjSdU6dJZWCy3+WeXWJe3g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lorenzo Colitti <lorenzo@google.com>
Date: Mon, 3 Jun 2013 18:25:39 +0900

> On Mon, Jun 3, 2013 at 5:43 PM, Cong Wang <amwang@redhat.com> wrote:
>> From: Cong Wang <amwang@redhat.com>
>>
>> If we don't need scope id, we should initialize it to zero.
>> Same for ->sin6_flowinfo.
>>
>> Cc: Lorenzo Colitti <lorenzo@google.com>
>> Cc: David S. Miller <davem@davemloft.net>
>> Signed-off-by: Cong Wang <amwang@redhat.com>
 ...
> Acked-by: Lorenzo Colitti <lorenzo@google.com>

Applied, thanks.
