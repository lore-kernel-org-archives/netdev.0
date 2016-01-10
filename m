From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [net-next PATCH 1/1] sched,cls_flower: set key address type when
 present
Date: Sun, 10 Jan 2016 11:48:47 -0500
Message-ID: <56928B6F.9090105@mojatatu.com>
References: <1452444421-3939-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:35746 "EHLO
	mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756833AbcAJQst (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jan 2016 11:48:49 -0500
Received: by mail-io0-f194.google.com with SMTP id 77so9368706ioc.2
        for <netdev@vger.kernel.org>; Sun, 10 Jan 2016 08:48:49 -0800 (PST)
In-Reply-To: <1452444421-3939-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,
This would also be considered a bug fix that needs to go -stable.

cheers,
jamal
On 16-01-10 11:47 AM, Jamal Hadi Salim wrote:
> From: Jamal Hadi Salim <jhs@mojatatu.com>
>
> only when user space passes the addresses should we consider their
> presence
>
> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
> Acked-by: Jiri Pirko <jiri@resnulli.us>
