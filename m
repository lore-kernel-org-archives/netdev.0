From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH v3 net-next 4/4] filter: add minimal BPF JIT emitted image
 disassembler
Date: Wed, 20 Mar 2013 19:57:03 +0100
Message-ID: <514A067F.50804@redhat.com>
References: <1363711172-9728-1-git-send-email-dborkman@redhat.com> <1363711172-9728-5-git-send-email-dborkman@redhat.com> <20130320.131713.988538863586629681.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:61447 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757229Ab3CTS5K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Mar 2013 14:57:10 -0400
In-Reply-To: <20130320.131713.988538863586629681.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/20/2013 06:17 PM, David Miller wrote:
> From: Daniel Borkmann <dborkman@redhat.com>
> Date: Tue, 19 Mar 2013 17:39:32 +0100
>
>> This is a minimal stand-alone user space helper, that allows for debugging or
>> verification of emitted BPF JIT images.
>
> As Ben Hutchings suggested, please respin this such that the tool
> goes somewhere under tools/
>
> Creating a tools/net/ subdirectory for small programs like this is
> fine.

Thanks, I'll do that!
