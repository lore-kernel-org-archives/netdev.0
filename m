From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH -next] net: sched: pkt_cls: remove unused macros from
 uapi
Date: Thu, 21 May 2015 09:42:36 -0400
Message-ID: <555DE0CC.3030803@mojatatu.com>
References: <1432167984-3612-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com
To: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:34004 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756168AbbEUNmi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2015 09:42:38 -0400
Received: by ieczm2 with SMTP id zm2so8374762iec.1
        for <netdev@vger.kernel.org>; Thu, 21 May 2015 06:42:38 -0700 (PDT)
In-Reply-To: <1432167984-3612-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/20/15 20:26, Florian Westphal wrote:
> Jamal points out that this header also contains kernel internal magic that
> cannot be used from userspace for anything meaningful.
>
> Lets remove what the kernel doesn't use anymore and wrap remainder with
> __KERNEL__.
>
> Suggested-by: Jamal Hadi Salim <jhs@mojatatu.com>
> Suggested-by: Alexei Starovoitov <alexei.starovoitov@gmail.com>
> Signed-off-by: Florian Westphal <fw@strlen.de>
> ---

Thanks Florian. This one deserves:
Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>


cheers,
jamal
