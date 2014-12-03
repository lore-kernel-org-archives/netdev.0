From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next 6/6] net_sched: cls_cgroup: remove unnecessary
 if
Date: Wed, 03 Dec 2014 09:30:48 -0500
Message-ID: <547F1E98.1050704@mojatatu.com>
References: <1417539636-12710-1-git-send-email-jiri@resnulli.us> <1417539636-12710-7-git-send-email-jiri@resnulli.us> <547F0AFA.7090001@mojatatu.com> <20141203131815.GF1860@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:62573 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753112AbaLCOaz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2014 09:30:55 -0500
Received: by mail-ie0-f169.google.com with SMTP id y20so13892725ier.0
        for <netdev@vger.kernel.org>; Wed, 03 Dec 2014 06:30:55 -0800 (PST)
In-Reply-To: <20141203131815.GF1860@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/03/14 08:18, Jiri Pirko wrote:

>>
>> Hrm. head could be NULL, no?
>
> Sure it can. But that is not a problem. Not sure what you are trying to
> point at...
>

I suppose head->handle MUST always be equal to handle for the change to
work. So doesnt matter if handle is null or not. Too clever for me.

Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal
