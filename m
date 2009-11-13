From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: [net-next-2.6 PATCH v6 5/7 RFC] TCPCT part 1e: implement socket
 option TCP_COOKIE_TRANSACTIONS
Date: Fri, 13 Nov 2009 11:32:12 -0500
Message-ID: <4AFD8A0C.50008@gmail.com>
References: <4AFCDA9E.8050003@gmail.com> <4AFCEA59.3060707@gmail.com> <87bpj6tszv.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f221.google.com ([209.85.220.221]:51889 "EHLO
	mail-fx0-f221.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755239AbZKMQcM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2009 11:32:12 -0500
Received: by fxm21 with SMTP id 21so652622fxm.21
        for <netdev@vger.kernel.org>; Fri, 13 Nov 2009 08:32:17 -0800 (PST)
In-Reply-To: <87bpj6tszv.fsf@basil.nowhere.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andi Kleen wrote:
> BTW if you add new socket options you should always submit a manpage
> patch to linux-man@vger.kernel.org too
> 
Thanks muchly, I'd wondered where one does that!  I'll do that as soon
as the code goes into the net tree (rather than net-next) for staging
out to the main line, as otherwise that could be pretty confusing for
others (non-existent options).

I'd found Documentation/networking/ip-sysctl.txt, updated in part 1c.

Any technical corrections to this patch (or part 1c)?
