From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH 1/2] net: add dev_uc_sync_multiple() and dev_mc_sync_multiple()
 api
Date: Mon, 15 Apr 2013 15:48:20 -0400
Message-ID: <516C5984.7040707@redhat.com>
References: <1366052997-12435-1-git-send-email-vyasevic@redhat.com> <1366052997-12435-2-git-send-email-vyasevic@redhat.com> <20130415.154455.853917359652831496.davem@davemloft.net>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:7208 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753366Ab3DOTsZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Apr 2013 15:48:25 -0400
In-Reply-To: <20130415.154455.853917359652831496.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/15/2013 03:44 PM, David Miller wrote:
> From: Vlad Yasevich <vyasevic@redhat.com>
> Date: Mon, 15 Apr 2013 15:09:56 -0400
>
>> The current implementation of dev_uc_sync/unsync() assumes that there is
>> a strict 1-to-1 relationship between the source and destination of the case.
>
> What do you mean by "destination of the case", maybe use different words
> here.

That should be "source and destination of the sync".

will fix.

-vlad
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
