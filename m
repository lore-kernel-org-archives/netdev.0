From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next v3] pktgen: support net namespace
Date: Tue, 29 Jan 2013 15:18:11 -0500 (EST)
Message-ID: <20130129.151811.2254129177456286731.davem@davemloft.net>
References: <1359438953-23703-1-git-send-email-amwang@redhat.com>
	<87txq0h5xf.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: amwang@redhat.com, netdev@vger.kernel.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59797 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751305Ab3A2USP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2013 15:18:15 -0500
In-Reply-To: <87txq0h5xf.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Mon, 28 Jan 2013 22:14:20 -0800

> Cong Wang <amwang@redhat.com> writes:
> 
>> From: Cong Wang <amwang@redhat.com>
>>
>> v3: make pktgen_threads list per-namespace
>> v2: remove a useless check
>>
>> This patch add net namespace to pktgen, so that
>> we can use pktgen in different namespaces.
>>
>> Cc: Eric W. Biederman <ebiederm@xmission.com>
>> Cc: David S. Miller <davem@davemloft.net>
>> Signed-off-by: Cong Wang <amwang@redhat.com>
> 
> This looks like a basic straight forward conversion to me.
> 
> Acked-by: "Eric W. Biederman" <ebiederm@xmission.com>

Applied, thanks.
