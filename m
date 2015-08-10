From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 08/10] ss: symmetrical subhandler output extension example
Date: Mon, 10 Aug 2015 21:19:44 +0300
Message-ID: <55C8EB40.1000906@cogentembedded.com>
References: <1439162006-11421-1-git-send-email-matthias.tafelmeier@gmx.net>
 <1439162006-11421-9-git-send-email-matthias.tafelmeier@gmx.net>
 <55C896BA.8040408@cogentembedded.com>
 <1439218395.1084.4.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Matthias Tafelmeier <matthias.tafelmeier@gmx.net>,
	netdev@vger.kernel.org, hagen@jauu.net, shemminger@osdl.org,
	fw@strlen.de, edumazet@google.com, daniel@iogearbox.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f172.google.com ([209.85.217.172]:33852 "EHLO
	mail-lb0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932351AbbHJSTr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Aug 2015 14:19:47 -0400
Received: by lbbtg9 with SMTP id tg9so62101027lbb.1
        for <netdev@vger.kernel.org>; Mon, 10 Aug 2015 11:19:46 -0700 (PDT)
In-Reply-To: <1439218395.1084.4.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/10/2015 05:53 PM, Eric Dumazet wrote:

>>      {} not needed. I guess you haven't run your patches thru
>> scripts/checkpatch.pl?

> Yes, although this is missing from iproute2 sources ;)

    Oh, sorry, somehow I thought it's a kernel patch. :-)

MBR, Sergei
