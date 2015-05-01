From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v2 net-next] tc: remove unused redirect ttl
Date: Fri, 01 May 2015 22:20:15 +0300
Message-ID: <5543D1EF.5050401@cogentembedded.com>
References: <1430449896-5406-1-git-send-email-ast@plumgrid.com> <55435313.9030706@cogentembedded.com> <5543B7D6.9050508@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f172.google.com ([209.85.217.172]:35796 "EHLO
	mail-lb0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751726AbbEATUS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2015 15:20:18 -0400
Received: by lbbuc2 with SMTP id uc2so70297395lbb.2
        for <netdev@vger.kernel.org>; Fri, 01 May 2015 12:20:17 -0700 (PDT)
In-Reply-To: <5543B7D6.9050508@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/1/2015 8:28 PM, Alexei Starovoitov wrote:

>>> improves ingress+u32 performance from 22.4 Mpps to 22.9 Mpps

>>> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
>>> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
>>> ---
>>> The code is from Jamal. I only did testing and benchmarking.

>>     Then your patch should have had:

>> From: Jamal Hadi Salim <jhs@mojatatu.com>

>> before the change log, no?

> I don't think that's how it works. I've applied Jamal's patch
> then fixed few minor things.

    You just said "I only did testing and benchmarking." :-)

> Therefore his SOB is on top and
> mine below. 'From' has no DCO meaning.

    Sorry, I don't know what DCO is, at least not in this context. :-)

> It's used from time to time
> in merge request summary, but that's a different case.

    I'm sure it's also used when you're submitting someone other's patches.

WBR, Sergei
