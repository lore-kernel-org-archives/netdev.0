From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch net-next] neigh: use neigh_parms_net() to get struct
 neigh_parms->net pointer
Date: Tue, 10 Dec 2013 15:11:16 -0800
Message-ID: <1386717076.30495.351.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1386716107-18843-1-git-send-email-jiri@resnulli.us>
	 <20131210.175929.828518960842627263.davem@davemloft.net>
	 <1386716965.30495.350.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qe0-f45.google.com ([209.85.128.45]:54202 "EHLO
	mail-qe0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750850Ab3LJXLX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 18:11:23 -0500
Received: by mail-qe0-f45.google.com with SMTP id 6so4727092qea.18
        for <netdev@vger.kernel.org>; Tue, 10 Dec 2013 15:11:23 -0800 (PST)
In-Reply-To: <1386716965.30495.350.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-12-10 at 15:09 -0800, Eric Dumazet wrote:

> 
> Yep, provided in commit e42ea986e4a4ca about 5 years ago ;)

Actually its older than that : commit 57da52c1e62c6
