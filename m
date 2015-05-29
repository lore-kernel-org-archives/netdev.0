From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next] bpf: allow BPF programs access skb->skb_iif
 and skb->dev->ifindex fields
Date: Thu, 28 May 2015 20:40:44 -0700
Message-ID: <5567DFBC.3080008@plumgrid.com>
References: <1432765839-7709-1-git-send-email-ast@plumgrid.com> <55676AFA.2030403@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:33568 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751769AbbE2Dkq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2015 23:40:46 -0400
Received: by padbw4 with SMTP id bw4so39541117pad.0
        for <netdev@vger.kernel.org>; Thu, 28 May 2015 20:40:45 -0700 (PDT)
In-Reply-To: <55676AFA.2030403@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/28/15 12:22 PM, Daniel Borkmann wrote:
>>
>> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
>
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>

btw, Daniel, your ack appeared on the mailing list, but didn't make
it into patchwork...
Same issue as I was having.
I noticed when I send email via gmail web interface it always
appears as separate thread and doesn't register in patchwork.
So now I've switched to mutt and thunderbird only :)
