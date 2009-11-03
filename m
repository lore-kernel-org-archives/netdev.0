From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] net: Support specifying the network namespace upon device creation.
Date: Tue, 03 Nov 2009 02:32:56 -0800
Message-ID: <m1639rew4n.fsf@fess.ebiederm.org>
References: <m1eioggeux.fsf@fess.ebiederm.org> <4AEFF7BB.4090301@gmail.com>
	<m1ws28ey3k.fsf@fess.ebiederm.org>
	<20091103.020555.156050455.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:47248 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750872AbZKCKc4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2009 05:32:56 -0500
In-Reply-To: <20091103.020555.156050455.davem@davemloft.net> (David Miller's message of "Tue\, 03 Nov 2009 02\:05\:55 -0800 \(PST\)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> From: ebiederm@xmission.com (Eric W. Biederman)
> Date: Tue, 03 Nov 2009 01:50:23 -0800
>
>> Eric Dumazet <eric.dumazet@gmail.com> writes:
>>>
>>> Very nice, with only one long line you could wrap differently.
>> 
>> Say again?  Was that very nice with respect to the rest of the patch?
>> Or sarcasm because I overlooked this wrap at 80 columns
>> opportunity in ipgre?
>
> It can also be argued that for functions, wrapping the args is
> worse because it makes grep output less useful.  In fact that's,
> I believe, Linus's most recent recommendation in this area :)

The arguments are already wrapped in this instance.

But since I don't have clear guidance to change the patch I
will leave it.

Eric


