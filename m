From: David Miller <davem@davemloft.net>
Subject: Re: pull request: batman-adv 2011-03-05
Date: Mon, 07 Mar 2011 01:19:22 -0800 (PST)
Message-ID: <20110307.011922.59669370.davem@davemloft.net>
References: <1299328122-21468-1-git-send-email-sven@narfation.org>
	<20110306.181432.104062354.davem@davemloft.net>
	<201103071001.39111.sven@narfation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: sven@narfation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46654
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752645Ab1CGJSr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2011 04:18:47 -0500
In-Reply-To: <201103071001.39111.sven@narfation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>
Date: Mon, 7 Mar 2011 10:01:36 +0100

> On Monday 07 March 2011 03:14:32 David Miller wrote:
>> Can you like sync with me when you have less than 20+ patches queued
>> up?
>> 
>> It's too much at once to reasonably review, and makes regressions take
>> longer to bisect when people hit them.
> 
> I'll try. The problem is that most of it is one work package (the removal of 
> orig_hash) which I got in this amount of patches.
> 
> What do you think about another pull request which only has some of the 
> cleanup/fixes and leave the rest for the time after 2.6.39-rc1 - so it may get 
> into 2.6.40?

I already pulled this stuff into net-next-2.6
