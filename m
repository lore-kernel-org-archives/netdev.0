From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP out of memory - possible bug [3.18.0-rc3] / sched?
Date: Sun, 04 Jan 2015 13:01:27 -0800
Message-ID: <1420405287.32621.8.camel@edumazet-glaptop2.roam.corp.google.com>
References: <5457D095.9070502@qdot.me>
	 <1415043704.1005.0.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150104084240.GA1710@x4>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tomasz Mloduchowski <q@qdot.me>, netdev@vger.kernel.org
To: Markus Trippelsdorf <markus@trippelsdorf.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:35212 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752865AbbADVB3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Jan 2015 16:01:29 -0500
Received: by mail-pa0-f41.google.com with SMTP id rd3so27393991pab.28
        for <netdev@vger.kernel.org>; Sun, 04 Jan 2015 13:01:29 -0800 (PST)
In-Reply-To: <20150104084240.GA1710@x4>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2015-01-04 at 09:42 +0100, Markus Trippelsdorf wrote:

> Any news on this issue?
> 
> I stumbled across the same problem today with 3.19.0-rc2:

What make you think it was fixed in 3.19.0-rc2 ?

Have you tried a bisection ?
