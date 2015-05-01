From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v2 net-next] tc: remove unused redirect ttl
Date: Fri, 01 May 2015 13:18:59 +0300
Message-ID: <55435313.9030706@cogentembedded.com>
References: <1430449896-5406-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f47.google.com ([209.85.215.47]:33785 "EHLO
	mail-la0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751257AbbEAKTD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2015 06:19:03 -0400
Received: by layy10 with SMTP id y10so61953429lay.0
        for <netdev@vger.kernel.org>; Fri, 01 May 2015 03:19:01 -0700 (PDT)
In-Reply-To: <1430449896-5406-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 5/1/2015 6:11 AM, Alexei Starovoitov wrote:

> improves ingress+u32 performance from 22.4 Mpps to 22.9 Mpps

> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
> ---
> The code is from Jamal. I only did testing and benchmarking.

    Then your patch should have had:

From: Jamal Hadi Salim <jhs@mojatatu.com>

before the change log, no?

> V1->V2: missed removal of unused 'dev' variable.

[...]

WBR, Sergei
