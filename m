From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next 2/6] net: sched: add percpu stats to actions
Date: Fri, 03 Jul 2015 06:48:04 -0400
Message-ID: <55966864.9050600@mojatatu.com>
References: <1435842455-30501-1-git-send-email-edumazet@google.com> <1435842455-30501-3-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Alexei Starovoitov <ast@plumgrid.com>,
	John Fastabend <john.fastabend@gmail.com>,
	Eric Dumazet <edumazet@gmail.com>
To: Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:36257 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754661AbbGCKsG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jul 2015 06:48:06 -0400
Received: by igrv9 with SMTP id v9so114657470igr.1
        for <netdev@vger.kernel.org>; Fri, 03 Jul 2015 03:48:06 -0700 (PDT)
In-Reply-To: <1435842455-30501-3-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/02/15 09:07, Eric Dumazet wrote:
> Reuse existing percpu infrastructure Jonh added for qdisc.
>

I am not big on typos - s/Jonh/John ? ;->

> This patch adds a new cpustats parameter to tcf_hash_create() and all
> actions pass false, meaning this patch should have no effect yet.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal
