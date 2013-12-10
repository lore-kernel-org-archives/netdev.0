From: Wang Weidong <weidong1991.wang@gmail.com>
Subject: Re: [PATCH v6 2/3] sctp: add check rto_min and rto_max in sysctl
Date: Tue, 10 Dec 2013 23:42:37 +0800
Message-ID: <52A7366D.4090309@gmail.com>
References: <1386643597-22156-1-git-send-email-wangweidong1@huawei.com> <1386643597-22156-3-git-send-email-wangweidong1@huawei.com> <52A72666.5010304@gmail.com> <52A730B9.7060909@gmail.com> <52A73167.6000106@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Vlad Yasevich <vyasevich@gmail.com>, nhorman@tuxdriver.com,
	davem@davemloft.net, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f50.google.com ([209.85.160.50]:63427 "EHLO
	mail-pb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750789Ab3LJPmR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 10:42:17 -0500
In-Reply-To: <52A73167.6000106@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2013/12/10 23:21, Daniel Borkmann wrote:
> On 12/10/2013 04:18 PM, Wang Weidong wrote:
> ...
>>>> +static int proc_sctp_do_rto_min(struct ctl_table *ctl, int write,
>>>> +                                void __user*buffer, size_t *lenp,
>>>                                           ^^^^
>>> Please put a space before the '*'.
> ...
>>>> +static int proc_sctp_do_rto_max(struct ctl_table *ctl, int write,
>>>> +                                void __user*buffer, size_t *lenp,
>>>                                           ^^^^
>>> Please put a space after the before the '*'.
>>>
>> Ok, I will fix them.
>> What Daniel point out is that? I no need to line up them?
>
> Yes, what Vlad pointed out to you is what I meant in my reply to
> your cover letter ...
Nice. I get it.

Thanks.
