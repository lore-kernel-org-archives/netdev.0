From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH -next 3/5] net: sched: remove FROM INGRESS/EGRESS
Date: Tue, 05 May 2015 12:51:23 +0200
Message-ID: <5548A0AB.9020702@iogearbox.net>
References: <1430765318-13788-1-git-send-email-fw@strlen.de> <1430765318-13788-4-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, alexei.starovoitov@gmail.com
To: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:58891 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752215AbbEEKvZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2015 06:51:25 -0400
In-Reply-To: <1430765318-13788-4-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/04/2015 08:48 PM, Florian Westphal wrote:
> use a single bit marker to indicate if skb originates from rx path.
>
> Signed-off-by: Florian Westphal <fw@strlen.de>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
