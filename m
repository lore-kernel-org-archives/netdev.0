From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [PATCH next-next-2.6] netdev: better dev_name_hash
Date: Mon, 26 Oct 2009 00:45:39 +0200
Message-ID: <200910260045.39494.opurdila@ixiacom.com>
References: <200910252158.53921.opurdila@ixiacom.com> <200910252355.32640.opurdila@ixiacom.com> <20091025224153.GB20987@nuttenaction>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:11787 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754181AbZJYWsc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Oct 2009 18:48:32 -0400
In-Reply-To: <20091025224153.GB20987@nuttenaction>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 26 October 2009 00:41:54 you wrote:
> * Octavian Purdila | 2009-10-25 23:55:32 [+0200]:
> >My results shows that new17 is better or very close to jhash2. And I think
> > its lighter then jhash too.
> 
> If new17 is very close to jhash/jhash2 then the cycles comes into play.
> Anyway, there is already a very potent hash interface in form of jhash{,2}.
> 

Ah, sorry for the confusion, jhash2 was a typo, I've only tested jhash.
