From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v2 net-next] tc: remove unused redirect ttl
Date: Fri, 01 May 2015 10:28:54 -0700
Message-ID: <5543B7D6.9050508@plumgrid.com>
References: <1430449896-5406-1-git-send-email-ast@plumgrid.com> <55435313.9030706@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:36436 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750923AbbEAR25 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2015 13:28:57 -0400
Received: by igblo3 with SMTP id lo3so43519629igb.1
        for <netdev@vger.kernel.org>; Fri, 01 May 2015 10:28:56 -0700 (PDT)
In-Reply-To: <55435313.9030706@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/1/15 3:18 AM, Sergei Shtylyov wrote:
> Hello.
>
> On 5/1/2015 6:11 AM, Alexei Starovoitov wrote:
>
>> improves ingress+u32 performance from 22.4 Mpps to 22.9 Mpps
>
>> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
>> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
>> ---
>> The code is from Jamal. I only did testing and benchmarking.
>
>     Then your patch should have had:
>
> From: Jamal Hadi Salim <jhs@mojatatu.com>
>
> before the change log, no?

I don't think that's how it works. I've applied Jamal's patch
then fixed few minor things. Therefore his SOB is on top and
mine below. 'From' has no DCO meaning. It's used from time to time
in merge request summary, but that's a different case.
