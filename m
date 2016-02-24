From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [net-next PATCH v2 1/5] introduce IFE action
Date: Wed, 24 Feb 2016 07:52:06 -0500
Message-ID: <56CDA776.6080403@mojatatu.com>
References: <1456231760-2513-1-git-send-email-jhs@emojatatu.com>
 <1456231760-2513-2-git-send-email-jhs@emojatatu.com>
 <56CC5F73.9080201@iogearbox.net> <56CC6F3E.6000106@mojatatu.com>
 <56CC84F2.8030909@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com,
	alexei.starovoitov@gmail.com, john.fastabend@gmail.com,
	dj@verizon.com
To: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f182.google.com ([209.85.223.182]:32926 "EHLO
	mail-io0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751507AbcBXMwI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2016 07:52:08 -0500
Received: by mail-io0-f182.google.com with SMTP id z135so36446265iof.0
        for <netdev@vger.kernel.org>; Wed, 24 Feb 2016 04:52:08 -0800 (PST)
In-Reply-To: <56CC84F2.8030909@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-02-23 11:12 AM, Daniel Borkmann wrote:
> On 02/23/2016 03:39 PM, Jamal Hadi Salim wrote:

>
> My question was rather: should the kernel enforce the IDs and only
> allow what the kernel dictates (and not in/out of tree modules)? If
> yes, then there would be no need for a module parameter (and the
> module param should be avoided in any case).
>

Maybe i should just take it out for now and assume whatever is
in the kernel are the only allowed metadata.

cheers,
jamal
