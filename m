From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next 2/2] sched: introduce vlan action
Date: Tue, 11 Nov 2014 07:34:01 -0500
Message-ID: <54620239.6010306@mojatatu.com>
References: <1415700789-9171-1-git-send-email-jiri@resnulli.us> <1415700789-9171-2-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, pshelar@nicira.com, therbert@google.com,
	edumazet@google.com, willemb@google.com, dborkman@redhat.com,
	mst@redhat.com, fw@strlen.de, Paul.Durrant@citrix.com,
	tgraf@suug.ch
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:36595 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751440AbaKKMeF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2014 07:34:05 -0500
Received: by mail-ie0-f174.google.com with SMTP id x19so11337440ier.19
        for <netdev@vger.kernel.org>; Tue, 11 Nov 2014 04:34:04 -0800 (PST)
In-Reply-To: <1415700789-9171-2-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/11/14 05:13, Jiri Pirko wrote:
> This tc action allows to work with vlan tagged skbs. Two supported
> sub-actions are header pop and header push.
>
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

Looks good. I am going to test it - but dont see any obvious issues I
from inspection; willing to say:

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal
