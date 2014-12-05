From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next] net: sched: cls: remove unused op put from tcf_proto_ops
Date: Fri, 05 Dec 2014 07:31:57 -0500
Message-ID: <5481A5BD.5000905@mojatatu.com>
References: <1417725678-24968-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f171.google.com ([209.85.223.171]:51791 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751216AbaLEMcA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2014 07:32:00 -0500
Received: by mail-ie0-f171.google.com with SMTP id rl12so578685iec.30
        for <netdev@vger.kernel.org>; Fri, 05 Dec 2014 04:31:59 -0800 (PST)
In-Reply-To: <1417725678-24968-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/04/14 15:41, Jiri Pirko wrote:
> It is never called and implementations are void. So just remove it.
>
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal
