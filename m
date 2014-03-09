From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] pkt_sched: fq: do not hold qdisc lock while allocating
 memory
Date: Sun, 09 Mar 2014 07:18:26 -0700
Message-ID: <1394374706.20149.94.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1394175472.20149.6.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140307.170450.1316250102185751283.davem@davemloft.net>
	 <1394233362.20149.47.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140308.191032.101129109368547659.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f44.google.com ([209.85.160.44]:39973 "EHLO
	mail-pb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751805AbaCIOS2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Mar 2014 10:18:28 -0400
Received: by mail-pb0-f44.google.com with SMTP id rp16so6206107pbb.3
        for <netdev@vger.kernel.org>; Sun, 09 Mar 2014 07:18:27 -0700 (PDT)
In-Reply-To: <20140308.191032.101129109368547659.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2014-03-08 at 19:10 -0500, David Miller wrote:

> Good point, this patch as-is is fine, so applied.

I see you applied it in net-next, but it should be in net tree

Thanks !
