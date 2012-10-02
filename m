From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net-next] vxlan: put UDP socket in correct namespace
Date: Tue, 02 Oct 2012 14:39:06 -0400 (EDT)
Message-ID: <20121002.143906.1620687170208944394.davem@davemloft.net>
References: <87626tbsgq.fsf@xmission.com>
	<20121001214921.78d9ed72@nehalam.linuxnetplumber.net>
	<87haqc7vii.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49800 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752264Ab2JBSjI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2012 14:39:08 -0400
In-Reply-To: <87haqc7vii.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Tue, 02 Oct 2012 08:18:13 -0700

> Stephen Hemminger <shemminger@vyatta.com> writes:
> 
>> Move vxlan UDP socket to correct network namespace
>>
>> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> Looks good from here.
> 
> Acked-by: "Eric W. Biederman" <ebiederm@xmission.com>

Applied, thanks.
