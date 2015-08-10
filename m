From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 08/10] ss: symmetrical subhandler output extension
 example
Date: Mon, 10 Aug 2015 07:53:15 -0700
Message-ID: <1439218395.1084.4.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1439162006-11421-1-git-send-email-matthias.tafelmeier@gmx.net>
	 <1439162006-11421-9-git-send-email-matthias.tafelmeier@gmx.net>
	 <55C896BA.8040408@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Matthias Tafelmeier <matthias.tafelmeier@gmx.net>,
	netdev@vger.kernel.org, hagen@jauu.net, shemminger@osdl.org,
	fw@strlen.de, edumazet@google.com, daniel@iogearbox.net
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:35452 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753150AbbHJOxQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Aug 2015 10:53:16 -0400
Received: by pacgr6 with SMTP id gr6so28654890pac.2
        for <netdev@vger.kernel.org>; Mon, 10 Aug 2015 07:53:16 -0700 (PDT)
In-Reply-To: <55C896BA.8040408@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-08-10 at 15:19 +0300, Sergei Shtylyov wrote:

>     {} not needed. I guess you haven't run your patches thru 
> scripts/checkpatch.pl?
> 

Yes, although this is missing from iproute2 sources ;)
