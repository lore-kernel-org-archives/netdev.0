From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bpf: allow BPF programs access skb->skb_iif
 and skb->dev->ifindex fields
Date: Thu, 28 May 2015 20:43:34 -0700 (PDT)
Message-ID: <20150528.204334.715132766357609717.davem@davemloft.net>
References: <1432765839-7709-1-git-send-email-ast@plumgrid.com>
	<55676AFA.2030403@iogearbox.net>
	<5567DFBC.3080008@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, netdev@vger.kernel.org
To: ast@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52822 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932240AbbE2Dnf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2015 23:43:35 -0400
In-Reply-To: <5567DFBC.3080008@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@plumgrid.com>
Date: Thu, 28 May 2015 20:40:44 -0700

> On 5/28/15 12:22 PM, Daniel Borkmann wrote:
>>>
>>> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
>>
>> Acked-by: Daniel Borkmann <daniel@iogearbox.net>
> 
> btw, Daniel, your ack appeared on the mailing list, but didn't make
> it into patchwork...
> Same issue as I was having.
> I noticed when I send email via gmail web interface it always
> appears as separate thread and doesn't register in patchwork.
> So now I've switched to mutt and thunderbird only :)

patchwork lost 22 hours of list traffic, but it should be functioning
normally now
